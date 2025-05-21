import 'package:flutter/material.dart';

class AcercaDePage extends StatelessWidget {
  const AcercaDePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),  
      appBar: AppBar(
        backgroundColor: const Color(0xFF66FF66), 
        title: const Text(
          "Acerca de",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.museum,
                size: 80,
                color: const Color(0xFF66FF66), 
              ),
              const SizedBox(height: 20),
              Text(
                "Museos de Quito",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                "Versión 1.0.0",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                "Nuestra Misión"
                "Te ayudamos a que visites y conozcas más de la diversidad del Ecuador. Aquí te orientamos para que explores los museos más clásicos e históricos de nuestro país."
                "¿Qué Ofrecemos?"
                "Nuestra aplicación te permite:"
                "Descubrir museos emblemáticos y su historia."
                "Guardar tus museos favoritos."
                "Encontrar información útil para tu visita (ubicación, horarios, tarifas, etc.)."
                "¡Explora y vive la cultura de Ecuador a través de sus museos!",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              const Text(
                "© 2025 - Desarrollado por mi desde los Guabos jsjsjsj",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
