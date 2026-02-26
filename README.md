# 🐻 Animated Bear Login

Welcome to the **Animated Bear Login** project!  
This is an **interactive Flutter login screen** with a cute bear character that reacts to your input.

The project demonstrates how to integrate **Rive animations** with Flutter using a **State Machine** to create dynamic and responsive UI interactions.

---

## 🎓 Academic Information

- **Course Name:** [Graphication]  
- **Teacher's Name:** [Rodrigo Fidel Gaxiola Sosa]  

---

## ✨ Features

- 👀 **Eye-tracking:** The bear follows your email input with its eyes.  
- 🙈 **Privacy mode:** The bear covers its eyes when typing the password.  
- 😁 **Happy bear:** Appears when login credentials are correct ( Admin@gmail.com / Admin12345 ).  
- 😢 **Sad bear:** Appears when login credentials are incorrect.  
- 🎨 Smooth animations powered by **Rive**.  

---

## 📚 Theory

### 🎨 What is Rive?

**Rive** is a real-time interactive animation tool that allows developers and designers to create state-driven animations.  
Unlike traditional static animations, Rive animations can react dynamically to user input through code.

In this project, Rive is used to animate the bear character and control its reactions based on user interactions in the login form.

---

### 🔄 What is a State Machine?

A **State Machine** is a logic system that transitions between different animation states depending on input values.

In this project, the Rive State Machine (`Login Machine`) contains inputs such as:

- `isChecking` → Controls whether the bear looks at the email field.
- `isHandsUp` → Controls whether the bear covers its eyes.
- `trigSuccess` → Triggers the happy animation.
- `trigFail` → Triggers the sad animation.

These inputs are connected in Flutter using:

- `SMIBool` → Boolean inputs (true/false states)
- `SMITrigger` → Event-based triggers

The animation reacts dynamically depending on user focus, typing behavior, and login validation.

---

## 🛠 Technologies

- 💙 Flutter 3.x
- 🎯 Dart 3.x
- 🎨 Rive

---

## 🧰 Requirements

- Flutter 3.x or higher  
- Dart 3.x  
- Rive package:

```yaml
dependencies:
  flutter:
    sdk: flutter
  rive: ^0.13.2
```

Rive animation file:  
`assets/animated_login_character.riv` with state machine **Login Machine**.

---

## 🚀 Installation

### 1- Clone the repository:

```bash
git clone <your_project_url>
```

### 2- Navigate to the project folder:

```bash
cd flutter_application_1
```

### 3- Install dependencies:

```bash
flutter pub get
```

### 4- Run the project:

```bash
flutter run
```

---

## 🎮 Usage

Enter your email  

The bear will follow your typing with its eyes.

Enter your password  

The bear automatically covers its eyes.

Press Login  

✅ Correct credentials ( Admin@gmail.com / Admin12345 ) → Bear becomes happy  

❌ Wrong credentials → Bear becomes sad  

---

## 📁 Project Structure

```
lib/
├── main.dart               # Entry point
├── login_screen.dart       # Login screen with Rive animation
assets/
├── animated_login_character.riv   # Bear animation file
pubspec.yaml                # Dependencies and Flutter config
```

---

## 🎥 DEMO

![Demo](./assets/Osito.gif)

---

## 👏 Credits

- **Animation Creator:** [dexterc]  
- **Original Animation Link:** [https://rive.app/marketplace/3645-7621-remix-of-login-machine/]  

---

💡 This project is designed for educational purposes to demonstrate Flutter + Rive integration using State Machines for interactive UI experiences.
