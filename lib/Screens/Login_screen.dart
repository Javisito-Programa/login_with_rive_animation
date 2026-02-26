import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async'; //3.1 importa el timer para poder usarlo en la función de login simulado

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  // Variables para controlar la animación
  StateMachineController? _controller;
  //SMI se usa para State Machine Input, es decir, para controlar los inputs de la máquina de estados en Rive
  //Que es input? Es una variable que la máquina de estados puede leer para cambiar su comportamiento. Por ejemplo, en este caso, el oso tiene inputs para saber si el usuario está escribiendo en el campo de email, si está escribiendo en el campo de password, etc. Entonces, dependiendo de esos inputs, el oso cambia su animación (mira el campo, se tapa los ojos, etc.)
  SMIBool? _isChecking; // Agregamos el input para mirar el campo de email
  SMIBool? _isHandsUp; // Agregamos el input para manos arriba
  SMITrigger? _isSuccess; // Agregamos el trigger para éxito
  SMITrigger? _trigFail; // Agregamos el trigger para fallo

  // Agregamos el input para controlar la dirección de la mirada del oso, esto nos permitirá hacer que el oso mire hacia el campo de email o hacia el campo de password dependiendo de dónde esté escribiendo el usuario
  SMINumber?
  _numlook; // Agregamos el input para controlar la dirección de la mirada del oso

  //1.1) Crear varables para FocusNode
  final _emailFocusNode =
      FocusNode(); // Creamos un FocusNode para el campo de email, esto nos permitirá detectar cuando el usuario enfoca o desenfoca ese campo
  final _passwordFocusNode = FocusNode();

  //3.2 Timer para detener mirada
  Timer?
  _typingDebounce; // Timer para detener la mirada después de un tiempo sin escribir, esto es para evitar que el oso mire hacia el infinito cuando el usuario deja de escribir pero no desenfoca el campo

  //1.2) Agregar listeners a los FocusNode para detectar cuando el usuario enfoca o desenfoca los campos de texto
  @override
  void initState() {
    // El initState se ejecuta cuando el widget se crea por primera vez, es el lugar ideal para agregar los listeners a los FocusNode
    super
        .initState(); // Agregamos listeners a los FocusNode para detectar cuando el usuario enfoca o desenfoca los campos de texto
    _emailFocusNode.addListener(() {
      //listener es una función que se ejecuta cada vez que cambia el estado de enfoque del campo de texto, es decir, cada vez que el usuario enfoca o desenfoca el campo de email
      // Manos arriba cuando el usuario enfoca el campo de email, manos abajo cuando desenfoca
      //Que es focusNode.hasFocus? Es una propiedad que nos dice si el campo de texto está enfocado o no. Entonces, si el usuario enfoca el campo de email, hasFocus será true, y si desenfoca, hasFocus será false. Entonces, dependiendo de eso, podemos cambiar el estado del oso.
      if (_emailFocusNode.hasFocus) {
        // Si el usuario enfoca el campo de email, el oso mira el campo
        if (_isHandsUp != null) {
          _isHandsUp!.change(false); // Bajamos las manos
          //2.2 mirada neutral, el oso mira al frente
          _numlook?.value = 50.0; // Mirada neutral, el oso mira al frente
        }
      }
    });
    _passwordFocusNode.addListener(() {
      // Manos arriba cuando el usuario enfoca el campo de password, manos abajo cuando desenfoca
      _isHandsUp?.change(_passwordFocusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              SizedBox(
                width: size.width,
                height: 250, // Un poco más de espacio para el oso
                child: RiveAnimation.asset(
                  'assets/animated_login_bear.riv',
                  stateMachines: const ['Login Machine'],
                  onInit: (artboard) {
                    _controller = StateMachineController.fromArtboard(
                      artboard,
                      'Login Machine',
                    );
                    //Verificamos que inicializamos el controlador correctamente, si no, salimos para evitar errores
                    if (_controller == null) return; // Si falla, salimos
                    // Agregamos el controlador al artboard
                    artboard.addController(_controller!);
                    // Vinculamos los inputs
                    _isChecking = _controller!.findSMI(
                      'isChecking',
                    ); // Para mirar el campo de email
                    _isHandsUp = _controller!.findSMI(
                      'isHandsUp',
                    ); // Para manos arriba
                    _isSuccess = _controller!.findSMI(
                      'trigSuccess',
                    ); // Para disparar éxito
                    _trigFail = _controller!.findSMI(
                      'trigFail',
                    ); // Para disparar fallo
                    //vincular numlook para controlar la dirección de la mirada del oso
                    _numlook = _controller!.findSMI(
                      'numlook',
                    ); // Para controlar la dirección de la mirada del oso

                    // Estado inicial: mirada neutral
                    _numlook?.value = 50.0;
                  },
                ),
              ),
              const SizedBox(height: 10),
              //Campo de texto para email
              TextField(
                //1.3) Asignar los FocusNode a los campos de texto correspondientes
                focusNode:
                    _emailFocusNode, // Asignamos el FocusNode al campo de email
                onChanged: (value) {
                  // Cuando el usuario escribe, el oso mira el campo
                  // Solo actualizamos si el campo de email está enfocado
                  if (_emailFocusNode.hasFocus) {
                    if (_isHandsUp != null) {
                      //No quiero modo chismoso, así que el oso no mira el campo de email, solo baja las manos
                      //2.4 Implementar numlook
                      //Estoy escribiendo
                      // _isHandsUp!.change(true); // Bajamos las manos
                      // Calculamos el valor de numlook en función de la longitud del texto, asumiendo que el máximo es 30 caracteres
                      double lookValue = (value.length / 30.0 * 100).clamp(
                        0,
                        100,
                      );
                      _numlook?.value =
                          lookValue; // Miramos según la longitud del texto
                    }
                    // Si el campo no está vacío, el oso mira, si está vacío, el oso baja la mirada
                    if (_isChecking == null) return;
                    // Si el campo tiene texto, el oso mira, si está vacío, el oso baja la mirada
                    _isChecking!.change(true);

                    //3.3 Debounce si vuelve a teclear, reiniciar contador
                    _typingDebounce?.cancel(); // Cancelamos el timer anterior
                    //Crear nuevo timer
                    _typingDebounce = Timer(const Duration(seconds: 3), () {
                      //Si se cierra la pantalla quitamos el timer para evitar errores
                      if (!mounted) return;
                      //Mirada neutra después de 3 segundos sin escribir
                      _numlook?.value = 50.0;
                      _isChecking!.change(false); // Dejamos de mirar el campo
                    });
                  }
                },
                // El teclado de email es más adecuado para este campo, ya que muestra el símbolo @ y el .com, lo que facilita la escritura del email
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText:
                      'Email', // El hintText es el texto que aparece dentro del campo de texto cuando está vacío, es una pista para el usuario sobre qué debe escribir en ese campo
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                //1.3) Asignar los FocusNode a los campos de texto correspondientes
                focusNode:
                    _passwordFocusNode, // Asignamos el FocusNode al campo de password
                onChanged: (value) {
                  // Cuando el usuario escribe en el campo de password
                  // Solo actualizamos si el campo de password está enfocado
                  if (_passwordFocusNode.hasFocus) {
                    // Calculamos el valor de numlook en función de la longitud del texto
                    double lookValue = (value.length / 80.0 * 100).clamp(
                      0,
                      100,
                    );
                    _numlook?.value = lookValue;

                    //Si HandsUp es null, salimos para evitar errores
                    if (_isHandsUp == null) return;
                    // Si el campo tiene texto, el oso baja las manos, si está vacío, el oso sube las manos
                    _isHandsUp!.change(value.isNotEmpty);

                    // Debounce para volver a mirada neutral después de 3 segundos
                    _typingDebounce?.cancel();
                    _typingDebounce = Timer(const Duration(seconds: 3), () {
                      if (!mounted) return;
                      _numlook?.value = 50.0; // Mirada neutral
                    });
                  }
                },
                onTap: () {
                  // Cuando el usuario va a escribir la clave, el oso se tapa los ojos
                  if (_isHandsUp != null) _isHandsUp!.value = true;
                },
                obscureText: _obscureText,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                        // Si mostramos la clave, el oso baja las manos
                        if (_isHandsUp != null)
                          _isHandsUp!.value = _obscureText;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  //1.4) Limpiar los FocusNode en el dispose para evitar fugas de memoria
  @override
  void dispose() {
    // Limpiamos los FocusNode para evitar fugas de memoria al salir de la pantalla
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _typingDebounce
        ?.cancel(); // Cancelamos el timer si está activo para evitar errores
    super.dispose();
  }
}
