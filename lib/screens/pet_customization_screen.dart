import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/pet_provider.dart';
import '../providers/language_provider.dart';
import 'package:calmy/providers/app_state.dart' ;
import '../widgets/gradient_background.dart';
import '../widgets/pet_avatar.dart';
import '../models/app_screen.dart' as models;

class PetCustomizationScreen extends StatefulWidget {
  const PetCustomizationScreen({super.key});

  @override
  State<PetCustomizationScreen> createState() => _PetCustomizationScreenState();
}

class _PetCustomizationScreenState extends State<PetCustomizationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this); // Aumentado a 6 tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = Provider.of<PetProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final appState = Provider.of<AppState>(context);
    final isSpanish = languageProvider.isSpanish;

    return Scaffold(
      body: GradientBackground(
        colors: const [
          Color(0xFF667eea),
          Color(0xFF764ba2),
          Color(0xFFf093fb),
        ],
        child: SafeArea(
          child: Column(
            children: [
              // Header mejorado
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Provider.of<AppState>(context, listen: false).navigateTo(models.AppScreen.home),
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            isSpanish ? '✨ Personalizar Mascota ✨' : '✨ Customize Pet ✨',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isSpanish ? 'Haz única a tu mascota' : 'Make your pet unique',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              
              // Pet preview mejorado
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.9),
                      Colors.white.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.purple.withOpacity(0.1),
                            Colors.pink.withOpacity(0.05),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: PetAvatar(
                        petProvider: petProvider,
                        size: 140,
                        showHeart: true,
                      ).animate().scale(duration: 600.ms).then().shimmer(),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        petProvider.config.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Tabs mejorados
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicator: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withOpacity(0.6),
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: [
                    Tab(text: isSpanish ? '🌟 Auras' : '🌟 Auras'),
                    Tab(text: isSpanish ? '🎨 Colores' : '🎨 Colors'),
                    Tab(text: isSpanish ? '🐾 Mascotas' : '🐾 Pets'),
                    Tab(text: isSpanish ? '🎩 Sombreros' : '🎩 Hats'),
                    Tab(text: isSpanish ? '👓 Gafas' : '👓 Glasses'),
                    Tab(text: isSpanish ? '👕 Ropa' : '👕 Clothes'),
                  ],
                ),
              ),

              // Tab content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAuraTab(petProvider, isSpanish),
                      _buildColorTab(petProvider, isSpanish),
                      _buildPetTab(petProvider, isSpanish),
                      _buildHatTab(petProvider, isSpanish),
                      _buildGlassesTab(petProvider, isSpanish),
                      _buildClothesTab(petProvider, isSpanish),
                    ],
                  ),
                ),
              ),

              // Save button mejorado
              Container(
                margin: const EdgeInsets.all(20),
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    petProvider.saveConfig(petProvider.config);
                    appState.unlockAchievement('pet_customized');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isSpanish ? '¡Mascota personalizada guardada!' : 'Pet customization saved!',
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF667eea),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 10,
                    shadowColor: Colors.black.withOpacity(0.3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        isSpanish ? 'Guardar Cambios' : 'Save Changes',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().scale(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuraTab(PetProvider petProvider, bool isSpanish) {
    final auras = [
      {'id': 'none', 'name': isSpanish ? 'Sin aura' : 'No aura', 'emoji': ''},
      {'id': 'sparkles', 'name': isSpanish ? 'Destellos' : 'Sparkles', 'emoji': '✨'},
      {'id': 'hearts', 'name': isSpanish ? 'Corazones' : 'Hearts', 'emoji': '💕'},
      {'id': 'stars', 'name': isSpanish ? 'Estrellas' : 'Stars', 'emoji': '⭐'},
      {'id': 'rainbow', 'name': isSpanish ? 'Arcoíris' : 'Rainbow', 'emoji': '🌈'},
      {'id': 'fire', 'name': isSpanish ? 'Fuego' : 'Fire', 'emoji': '🔥'},
      {'id': 'magic', 'name': isSpanish ? 'Magia' : 'Magic', 'emoji': '🪄'},
    ];

    return _buildCustomizationGrid(
      items: auras,
      currentValue: petProvider.config.aura,
      onSelect: (value) => petProvider.updateAura(value),
      isSpanish: isSpanish,
      title: isSpanish ? 'Elige un aura mágica' : 'Choose a magical aura',
    );
  }

  Widget _buildColorTab(PetProvider petProvider, bool isSpanish) {
    final colors = [
      {'id': '#9C27B0', 'name': isSpanish ? 'Púrpura' : 'Purple', 'color': const Color(0xFF9C27B0)},
      {'id': '#E91E63', 'name': isSpanish ? 'Rosa' : 'Pink', 'color': const Color(0xFFE91E63)},
      {'id': '#2196F3', 'name': isSpanish ? 'Azul' : 'Blue', 'color': const Color(0xFF2196F3)},
      {'id': '#4CAF50', 'name': isSpanish ? 'Verde' : 'Green', 'color': const Color(0xFF4CAF50)},
      {'id': '#FF9800', 'name': isSpanish ? 'Naranja' : 'Orange', 'color': const Color(0xFFFF9800)},
      {'id': '#F44336', 'name': isSpanish ? 'Rojo' : 'Red', 'color': const Color(0xFFF44336)},
      {'id': '#795548', 'name': isSpanish ? 'Marrón' : 'Brown', 'color': const Color(0xFF795548)},
      {'id': '#607D8B', 'name': isSpanish ? 'Gris azul' : 'Blue grey', 'color': const Color(0xFF607D8B)},
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isSpanish ? '🎨 Elige el color de tu mascota' : '🎨 Choose your pet\'s color',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF667eea),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1,
              ),
              itemCount: colors.length,
              itemBuilder: (context, index) {
                final color = colors[index];
                final isSelected = petProvider.config.color == color['id'];
                
                return GestureDetector(
                  onTap: () => petProvider.updateColor(color['id'] as String),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: color['color'] as Color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (color['color'] as Color).withOpacity(0.4),
                          blurRadius: isSelected ? 15 : 8,
                          spreadRadius: isSelected ? 3 : 1,
                        ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 30)
                        : null,
                  ),
                ).animate(delay: (index * 50).ms).scale();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetTab(PetProvider petProvider, bool isSpanish) {
    final pets = [
      {'id': 'cat', 'name': isSpanish ? 'Gato' : 'Cat', 'emoji': '🐱'},
      {'id': 'dog', 'name': isSpanish ? 'Perro' : 'Dog', 'emoji': '🐶'},
      {'id': 'rabbit', 'name': isSpanish ? 'Conejo' : 'Rabbit', 'emoji': '🐰'},
      {'id': 'bear', 'name': isSpanish ? 'Oso' : 'Bear', 'emoji': '🐻'},
      {'id': 'panda', 'name': isSpanish ? 'Panda' : 'Panda', 'emoji': '🐼'},
      {'id': 'fox', 'name': isSpanish ? 'Zorro' : 'Fox', 'emoji': '🦊'},
      {'id': 'lion', 'name': isSpanish ? 'León' : 'Lion', 'emoji': '🦁'},
      {'id': 'tiger', 'name': isSpanish ? 'Tigre' : 'Tiger', 'emoji': '🐯'},
    ];

    return _buildCustomizationGrid(
      items: pets,
      currentValue: petProvider.config.pet,
      onSelect: (value) => petProvider.updatePet(value),
      isSpanish: isSpanish,
      title: isSpanish ? 'Elige tu compañero ideal' : 'Choose your ideal companion',
    );
  }

  Widget _buildHatTab(PetProvider petProvider, bool isSpanish) {
    final hats = [
      {'id': 'none', 'name': isSpanish ? 'Sin sombrero' : 'No hat', 'emoji': ''},
      {'id': 'crown', 'name': isSpanish ? 'Corona' : 'Crown', 'emoji': '👑'},
      {'id': 'cap', 'name': isSpanish ? 'Gorra' : 'Cap', 'emoji': '🧢'},
      {'id': 'top_hat', 'name': isSpanish ? 'Sombrero de copa' : 'Top hat', 'emoji': '🎩'},
      {'id': 'party', 'name': isSpanish ? 'Gorro de fiesta' : 'Party hat', 'emoji': '🎉'},
      {'id': 'wizard', 'name': isSpanish ? 'Sombrero de mago' : 'Wizard hat', 'emoji': '🧙‍♂️'},
    ];

    return _buildCustomizationGrid(
      items: hats,
      currentValue: petProvider.config.hat,
      onSelect: (value) => petProvider.updateHat(value),
      isSpanish: isSpanish,
      title: isSpanish ? 'Elige un sombrero elegante' : 'Choose an elegant hat',
    );
  }

  Widget _buildGlassesTab(PetProvider petProvider, bool isSpanish) {
    final glasses = [
      {'id': 'none', 'name': isSpanish ? 'Sin gafas' : 'No glasses', 'emoji': ''},
      {'id': 'sunglasses', 'name': isSpanish ? 'Gafas de sol' : 'Sunglasses', 'emoji': '🕶️'},
      {'id': 'reading', 'name': isSpanish ? 'Gafas de lectura' : 'Reading glasses', 'emoji': '👓'},
      {'id': 'cool', 'name': isSpanish ? 'Gafas geniales' : 'Cool glasses', 'emoji': '😎'},
    ];

    return _buildCustomizationGrid(
      items: glasses,
      currentValue: petProvider.config.glasses,
      onSelect: (value) => petProvider.updateGlasses(value),
      isSpanish: isSpanish,
      title: isSpanish ? 'Elige unas gafas con estilo' : 'Choose stylish glasses',
    );
  }

  Widget _buildClothesTab(PetProvider petProvider, bool isSpanish) {
    final clothes = [
      {'id': 'none', 'name': isSpanish ? 'Sin ropa' : 'No clothes', 'emoji': ''},
      {'id': 'shirt', 'name': isSpanish ? 'Camiseta' : 'T-shirt', 'emoji': '👕'},
      {'id': 'dress', 'name': isSpanish ? 'Vestido' : 'Dress', 'emoji': '👗'},
      {'id': 'suit', 'name': isSpanish ? 'Traje' : 'Suit', 'emoji': '🤵'},
      {'id': 'hoodie', 'name': isSpanish ? 'Sudadera' : 'Hoodie', 'emoji': '🧥'},
      {'id': 'scarf', 'name': isSpanish ? 'Bufanda' : 'Scarf', 'emoji': '🧣'},
    ];

    return _buildCustomizationGrid(
      items: clothes,
      currentValue: petProvider.config.clothes,
      onSelect: (value) => petProvider.updateClothes(value),
      isSpanish: isSpanish,
      title: isSpanish ? 'Elige ropa fashionable' : 'Choose fashionable clothes',
    );
  }

  Widget _buildCustomizationGrid({
    required List<Map<String, dynamic>> items,
    required String currentValue,
    required Function(String) onSelect,
    required bool isSpanish,
    required String title,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF667eea),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.8,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = currentValue == item['id'];
                
                return GestureDetector(
                  onTap: () => onSelect(item['id'] as String),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            )
                          : LinearGradient(
                              colors: [Colors.grey[100]!, Colors.grey[50]!],
                            ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.grey[300]!,
                        width: isSelected ? 3 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected 
                              ? const Color(0xFF667eea).withOpacity(0.4)
                              : Colors.black.withOpacity(0.1),
                          blurRadius: isSelected ? 15 : 5,
                          offset:  Offset(0, isSelected ? 8 : 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (item['emoji'] != null && (item['emoji'] as String).isNotEmpty)
                          Text(
                            item['emoji'] as String,
                            style: const TextStyle(fontSize: 40),
                          )
                        else
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white.withOpacity(0.3) : Colors.grey[300],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.block,
                              color: isSelected ? Colors.white : Colors.grey[600],
                              size: 30,
                            ),
                          ),
                        const SizedBox(height: 12),
                        Text(
                          item['name'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.grey[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (isSelected) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isSpanish ? 'Seleccionado' : 'Selected',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ).animate(delay: (index * 100).ms).scale().fadeIn();
              },
            ),
          ),
        ],
      ),
    );
  }
}
