import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async'; //3.1 importa el timer para poder usarlo en la función de login simulado

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override //sirve para indicar que estamos sobrescribiendo un método de la clase padre, en este caso, el método createState de StatefulWidget
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
  _numLook; // Agregamos el input para controlar la dirección de la mirada del oso

  //1.1) Crear varables para FocusNode
  final _emailFocusNode =
      FocusNode(); // Creamos un FocusNode para el campo de email, esto nos permitirá detectar cuando el usuario enfoca o desenfoca ese campo
  final _passwordFocusNode = FocusNode();

  //3.2 Timer para detener mirada
  Timer?
  _typingDebounce; // Timer para detener la mirada después de un tiempo sin escribir, esto es para evitar que el oso mire hacia el infinito cuando el usuario deja de escribir pero no desenfoca el campo

  // 4.1 Controllers
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  // 4.2 Errores para mostrar en la UI
  String? emailError;
  String? passError;

  // 4.3 Validadores
  bool isValidEmail(String email) {
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(email);
  }

  bool isValidPassword(String pass) {
    // mínimo 8, una mayúscula, una minúscula, un dígito y un especial
    final re = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
    );
    return re.hasMatch(pass);
  }

  // 4.4 Acción al botón
  void _onLogin() {
    //De lo que el usuario escribió, tomamos el email y la contraseña, y les quitamos los espacios al inicio y al final con trim() para evitar errores de validación por espacios extra
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text;

    // Recalcular errores
    final eError = isValidEmail(email) ? null : 'Email inválido';
    final pError = isValidPassword(pass)
        ? null
        : 'Mínimo 8 caracteres, 1 mayúscula, 1 minúscula, 1 número y 1 caracter especial';

    // 4.5 Para avisar que hubo un cambio
    setState(() {
      emailError = eError;
      passError = pError;
    });

    // 4.6 Cerrar el teclado y bajar manos
    FocusScope.of(context).unfocus();
    _typingDebounce?.cancel();
    _isChecking?.change(false);
    _isHandsUp?.change(false);
    _numLook?.value = 50.0; // Mirada neutral

    // 4.7 Activar triggers
    if (eError == null && pError == null) {
      _isSuccess?.fire();
    } else {
      _trigFail?.fire();
    }
  }

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
          _numLook?.value = 50.0; // Mirada neutral, el oso mira al frente
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
    //MediaQuery.of(context).size nos da el tamaño de la pantalla, esto es útil para hacer que el diseño sea responsive, es decir, que se adapte a diferentes tamaños de pantalla. En este caso, lo usamos para hacer que la animación del oso ocupe un espacio adecuado en la pantalla sin importar el tamaño del dispositivo.
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          // Agregado para evitar error de espacio al subir el teclado
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
                    _numLook = _controller!.findSMI(
                      'numLook',
                    ); // Para controlar la dirección de la mirada del oso

                    // Estado inicial: mirada neutral
                    _numLook?.value = 50.0;
                  },
                ),
              ),
              const SizedBox(height: 10),
              //Campo de texto para email
              TextField(
                // Agregamos el campo de texto para email
                //4.8 Asignamos el controlador al campo de texto para email
                controller: emailCtrl,
                //1.3) Asignar los FocusNode a los campos de texto correspondientes
                focusNode:
                    _emailFocusNode, // Asignamos el FocusNode al campo de email
                onChanged: (value) {
                  //si checking no es nulo, activar el modo chismoso
                  if (_isChecking != null) {
                    //activar modo chismoso
                    _isChecking!.change(true);
                    //2.4 mover la mirada del oso al escribir el email
                    //ajustes de limites de 0 a 100
                    //80 como medida de calibracion
                    final look = (value.length / 80.0 * 100.0).clamp(
                      0.0,
                      100.0,
                    ); // es el rango de la abrazadera
                    _numLook?.value = look;

                    //3.3 Debounce: si vuelve a teclear, reinicia el contador
                    //cancelar cualquier timer existente
                    _typingDebounce?.cancel();
                    //crear un nuevo timer
                    _typingDebounce = Timer(const Duration(seconds: 2), () {
                      //si se cierra la pantalla, quita el timer
                      if (!mounted) return;
                      //mirada neutra
                      _isChecking?.change(false);
                    });
                  }
                },
                // El teclado de email es más adecuado para este campo, ya que muestra el símbolo @ y el .com, lo que facilita la escritura del email
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  errorText: emailError,
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
                //Campo de texto para password
                //4.8 Asignamos el controlador al campo de texto para password
                controller: passCtrl,
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
                    _numLook?.value = lookValue;

                    //Si HandsUp es null, salimos para evitar errores
                    if (_isHandsUp == null) return;
                    // Si el campo tiene texto, el oso baja las manos, si está vacío, el oso sube las manos
                    _isHandsUp!.change(!_obscureText || value.isEmpty);
                  }
                },
                onTap: () {
                  // Cuando el usuario va a escribir la clave, el oso se tapa los ojos
                  if (_isHandsUp != null && _obscureText)
                    _isHandsUp!.value = true;
                },
                obscureText: _obscureText,
                decoration: InputDecoration(
                  errorText: passError,
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
              const SizedBox(height: 10),
              //Texto de olvide mi contraseña
              SizedBox(
                width: size.width,
                child: GestureDetector(
                  onTap: () {
                    // Lógica para recuperar contraseña
                  },
                  child: const Text(
                    "Forgot password?",
                    textAlign: TextAlign.right,
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              MaterialButton(
                //Tomamos el ancho completo disponible para que sea más fácil de tocar
                minWidth: size.width,
                height: 50,
                color: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onPressed: _onLogin, // Conectado a la función de validación
                child: const Text(
                  "Login",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              //Texto de no tienes cuenta? registrate
              SizedBox(
                width: size.width,
                child: Row(
                  // Abrimos paréntesis del Row
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Alineamos al centro
                  children: [
                    // 'children' con minúscula
                    const Text("Don't have an account? "),
                    TextButton(
                      onPressed: () {
                        // Aquí iría la navegación a la pantalla de registro
                        print("Ir a Registro");
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.black,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ], // Cerramos lista de hijos
                ), // Cerramos Row
              ), // Cerramos SizedBox
            ],
          ),
        ),
      ),
    );
  }

  //1.4) Limpiar los FocusNode en el dispose para evitar fugas de memoria
  @override
  void dispose() {
    //4.11 Liberar controlers
    emailCtrl.dispose();
    passCtrl.dispose();
    // Limpiamos los FocusNode para evitar fugas de memoria al salir de la pantalla
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _typingDebounce
        ?.cancel(); // Cancelamos el timer si está activo para evitar errores
    super.dispose();
  }
}
