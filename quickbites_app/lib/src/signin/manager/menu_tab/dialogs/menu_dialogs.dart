import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbites_app/src/controllers/gerente_controller.dart';
import 'package:quickbites_app/src/models/mesa_model.dart';
import 'package:quickbites_app/src/models/platillo_model.dart';
import 'package:quickbites_app/src/models/categoria_model.dart';

void showAddMesaDialog(BuildContext context, GerenteController controller) {
  final nombreController = TextEditingController();
  final capacidadController = TextEditingController();
  bool ocupada = false;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Agregar Mesa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: 'Nombre de la Mesa'),
            ),
            TextField(
              controller: capacidadController,
              decoration: const InputDecoration(labelText: 'Capacidad'),
              keyboardType: TextInputType.number,
            ),
            Row(
              children: [
                const Text('Ocupada:'),
                Checkbox(
                  value: ocupada,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => ocupada = value);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final nombre = nombreController.text.trim();
              final capacidadText = capacidadController.text.trim();
              if (nombre.isEmpty || capacidadText.isEmpty) {
                Get.snackbar('Error', 'Nombre y Capacidad son obligatorios');
                return;
              }
              final capacidad = int.tryParse(capacidadText);
              if (capacidad == null) {
                Get.snackbar('Error', 'Capacidad debe ser un número');
                return;
              }
              controller.agregarMesa(MesaModel(
                numero: 2,
                nombre: nombre,
                capacidad: capacidad,
                ocupada: ocupada,
              ));
              Navigator.pop(context);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    ),
  );
}

void showEditMesaDialog(BuildContext context, GerenteController controller, MesaModel mesa) {
  final nombreController = TextEditingController(text: mesa.nombre);
  final capacidadController = TextEditingController(text: mesa.capacidad.toString());
  bool ocupada = mesa.ocupada;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Editar Mesa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: 'Nombre de la Mesa'),
            ),
            TextField(
              controller: capacidadController,
              decoration: const InputDecoration(labelText: 'Capacidad'),
              keyboardType: TextInputType.number,
            ),
            Row(
              children: [
                const Text('Ocupada:'),
                Checkbox(
                  value: ocupada,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => ocupada = value);
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final nombre = nombreController.text.trim();
              final capacidadText = capacidadController.text.trim();
              if (nombre.isEmpty || capacidadText.isEmpty) {
                Get.snackbar('Error', 'Nombre y Capacidad son obligatorios');
                return;
              }
              final capacidad = int.tryParse(capacidadText);
              if (capacidad == null) {
                Get.snackbar('Error', 'Capacidad debe ser un número');
                return;
              }
              controller.editarMesa(MesaModel(
                numero: 1,
                id: mesa.id,
                nombre: nombre,
                capacidad: capacidad,
                ocupada: ocupada,
              ));
              Navigator.pop(context);
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    ),
  );
}

void showAddPlatilloDialog(BuildContext context, GerenteController controller) {
  final nombreController = TextEditingController();
  final precioController = TextEditingController();
  String? selectedCategoria;
  String? selectedSubcategoria;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Agregar Platillo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: precioController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
              ),
              Obx(() => DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    value: selectedCategoria,
                    items: controller.categorias
                        .map((categoria) => DropdownMenuItem(
                              value: categoria.nombre,
                              child: Text(categoria.nombre),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategoria = value;
                        selectedSubcategoria = null;
                      });
                    },
                  )),
              if (selectedCategoria != null)
                Obx(() {
                  final categoria = controller.categorias.firstWhere(
                    (c) => c.nombre == selectedCategoria,
                    orElse: () => CategoriaModel(nombre: '', subcategorias: []),
                  );
                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Subcategoría'),
                    value: selectedSubcategoria,
                    items: categoria.subcategorias
                        .map((sub) => DropdownMenuItem(
                              value: sub,
                              child: Text(sub),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSubcategoria = value;
                      });
                    },
                  );
                }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final nombre = nombreController.text.trim();
              final precio = double.tryParse(precioController.text.trim());
              if (nombre.isEmpty || precio == null || selectedCategoria == null || selectedSubcategoria == null) {
                Get.snackbar('Error', 'Todos los campos son obligatorios');
                return;
              }
              controller.agregarPlatillo(PlatilloModel(
                nombre: nombre,
                precio: precio,
                categoria: selectedCategoria!,
                subcategoria: selectedSubcategoria!,
              ));
              Navigator.pop(context);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    ),
  );
}

void showEditPlatilloDialog(BuildContext context, GerenteController controller, PlatilloModel platillo) {
  final nombreController = TextEditingController(text: platillo.nombre);
  final precioController = TextEditingController(text: platillo.precio.toString());
  String? selectedCategoria = platillo.categoria;
  String? selectedSubcategoria = platillo.subcategoria;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Editar Platillo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: precioController,
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
              ),
              Obx(() => DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    value: selectedCategoria,
                    items: controller.categorias
                        .map((categoria) => DropdownMenuItem(
                              value: categoria.nombre,
                              child: Text(categoria.nombre),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategoria = value;
                        selectedSubcategoria = null;
                      });
                    },
                  )),
              if (selectedCategoria != null)
                Obx(() {
                  final categoria = controller.categorias.firstWhere(
                    (c) => c.nombre == selectedCategoria,
                    orElse: () => CategoriaModel(nombre: '', subcategorias: []),
                  );
                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Subcategoría'),
                    value: selectedSubcategoria,
                    items: categoria.subcategorias
                        .map((sub) => DropdownMenuItem(
                              value: sub,
                              child: Text(sub),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSubcategoria = value;
                      });
                    },
                  );
                }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final nombre = nombreController.text.trim();
              final precio = double.tryParse(precioController.text.trim());
              if (nombre.isEmpty || precio == null || selectedCategoria == null || selectedSubcategoria == null) {
                Get.snackbar('Error', 'Todos los campos son obligatorios');
                return;
              }
              controller.editarPlatillo(PlatilloModel(
                id: platillo.id,
                nombre: nombre,
                precio: precio,
                categoria: selectedCategoria!,
                subcategoria: selectedSubcategoria!,
              ));
              Navigator.pop(context);
            },
            child: const Text('Actualizar'),
          ),
        ],
      ),
    ),
  );
}

void showAddCategoriaDialog(BuildContext context, GerenteController controller) {
  final nombreController = TextEditingController();
  final subcategoriasController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Agregar Categoría'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nombreController,
            decoration: const InputDecoration(labelText: 'Nombre de la Categoría'),
          ),
          TextField(
            controller: subcategoriasController,
            decoration: const InputDecoration(labelText: 'Subcategorías (separadas por comas)'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            final nombre = nombreController.text.trim();
            final subcategoriasText = subcategoriasController.text.trim();
            if (nombre.isEmpty) {
              Get.snackbar('Error', 'El nombre no puede estar vacío');
              return;
            }
            final subcategorias = subcategoriasText.split(',').map((s) => s.trim()).toList();
            controller.agregarCategoria(CategoriaModel(
              nombre: nombre,
              subcategorias: subcategorias,
            ));
            Navigator.pop(context);
          },
          child: const Text('Agregar'),
        ),
      ],
    ),
  );
}

void showEditCategoriaDialog(BuildContext context, GerenteController controller, CategoriaModel categoria) {
  final subcategoriasController = TextEditingController(text: categoria.subcategorias.join(', '));

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Editar Categoría: ${categoria.nombre}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: subcategoriasController,
            decoration: const InputDecoration(labelText: 'Subcategorías (separadas por comas)'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () {
            final subcategoriasText = subcategoriasController.text.trim();
            final subcategorias = subcategoriasText.split(',').map((s) => s.trim()).toList();
            controller.editarCategoria(CategoriaModel(
              nombre: categoria.nombre,
              subcategorias: subcategorias,
            ));
            Navigator.pop(context);
          },
          child: const Text('Actualizar'),
        ),
      ],
    ),
  );
}