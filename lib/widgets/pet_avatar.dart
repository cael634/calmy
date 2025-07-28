import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pet_provider.dart';

class PetAvatar extends StatelessWidget {
  final double size;
  final bool showHeart;
  final bool showAura;
  final PetProvider? petProvider;

  const PetAvatar({
    Key? key,
    this.size = 80,
    this.showHeart = false,
    this.showAura = false,
    this.petProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<PetProvider>(
      builder: (context, provider, child) {
        final pet = petProvider ?? provider;
      
        // Convertir string de color a Color
        Color petColor = Colors.purple;
        try {
          if (pet.config.color.startsWith('#')) {
            petColor = Color(int.parse(pet.config.color.substring(1), radix: 16) + 0xFF000000);
          }
        } catch (e) {
          petColor = Colors.purple;
        }

        return SizedBox(
          width: size * 1.5, // Hacer el contenedor más grande para acomodar elementos externos
          height: size * 1.5,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Clothes - atrás del pet y más abajo, sin limitación del círculo
              if (pet.getClothesEmoji().isNotEmpty)
                Positioned(
                  bottom: size * 0.1, // Más abajo del pet
                  child: Text(
                    pet.getClothesEmoji(),
                    style: TextStyle(fontSize: size * 0.4),
                  ),
                ),

              // Círculo principal del pet
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      petColor.withOpacity(0.3),
                      petColor.withOpacity(0.1),
                    ],
                  ),
                  border: Border.all(
                    color: petColor.withOpacity(0.5),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: petColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pet emoji
                    Text(
                      pet.getPetEmoji(),
                      style: TextStyle(fontSize: size * 0.6),
                    ),

                    // Gafas - centradas en el pet
                    if (pet.getGlassesEmoji().isNotEmpty)
                      Text(
                        pet.getGlassesEmoji(),
                        style: TextStyle(fontSize: size * 0.5),
                      ),

                    // Heart indicator
                    if (showHeart)
                      Positioned(
                        top: size * 0.1,
                        left: size * 0.1,
                        child: const Text('💖', style: TextStyle(fontSize: 16)),
                      ),
                  ],
                ),
              ),

              // Aura effect - mostrar siempre si no es 'none'
              if (pet.config.aura != 'none' && pet.getAuraEmoji().isNotEmpty)
                Positioned(
                  top: size * 0.15,
                  right: size * 0.15,
                  child: Text(
                    pet.getAuraEmoji(),
                    style: TextStyle(fontSize: size * 0.3),
                  ),
                ),

              // Hat - más arriba de la posición actual
              if (pet.getHatEmoji().isNotEmpty)
                Positioned(
                  top: size * 0.05, // Un poco más arriba que antes
                  child: Text(
                    pet.getHatEmoji(),
                    style: TextStyle(fontSize: size * 0.4),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
