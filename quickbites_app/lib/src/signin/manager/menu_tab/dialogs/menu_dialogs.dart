import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quickbites_app/src/controllers/gerente_controller.dart';
import 'package:quickbites_app/src/models/mesa_model.dart';
import 'package:quickbites_app/src/models/platillo_model.dart';
import 'package:quickbites_app/src/models/categoria_model.dart';

void showAddMesaDialog(BuildContext context, GerenteController controller) {
  final nombreController = TextEditingController();
  final capacidadController = TextEditingController();

  showDialog(
    context: context,
    builder:
        (context) => StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                backgroundColor: Color(0xFFF2F2F2), // Fondo más suave y sólido
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  color: Color(0xFF3E2723), // Color de fondo del encabezado
                  child: Text(
                    'Agregar Mesa',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                content: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nombreController,
                        decoration: InputDecoration(
                          labelText: 'Nombre de la Mesa',
                          labelStyle: TextStyle(color: Colors.black54),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black54),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF3E2723)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        style: TextStyle(color: Colors.black),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: capacidadController,
                        decoration: InputDecoration(
                          labelText: 'Capacidad',
                          labelStyle: TextStyle(color: Colors.black54),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black54),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF3E2723)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF3E2723),
                            padding: EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            final nombre = nombreController.text.trim();
                            final capacidadText =
                                capacidadController.text.trim();
                            if (nombre.isEmpty || capacidadText.isEmpty) {
                              Get.snackbar(
                                'Error',
                                'Nombre y Capacidad son obligatorios',
                              );
                              return;
                            }
                            final capacidad = int.tryParse(capacidadText);
                            if (capacidad == null) {
                              Get.snackbar(
                                'Error',
                                'Capacidad debe ser un número',
                              );
                              return;
                            }
                            controller.agregarMesa(
                              MesaModel(
                                numero: 2,
                                nombre: nombre,
                                capacidad: capacidad,
                                ocupada: false,
                              ),
                            );
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Agregar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        ),
  );
}

void showEditMesaDialog(
  BuildContext context,
  GerenteController controller,
  MesaModel mesa,
) {
  final nombreController = TextEditingController(text: mesa.nombre);
  final capacidadController = TextEditingController(
    text: mesa.capacidad.toString(),
  );

  showDialog(
    context: context,
    builder:
        (context) => StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                backgroundColor: Color(0xFFF2F2F2), // Fondo más suave y sólido
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  color: Color(0xFF3E2723), // Color de fondo del encabezado
                  child: Text(
                    'Editar Mesa',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                content: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nombreController,
                        decoration: InputDecoration(
                          labelText: 'Nombre de la Mesa',
                          labelStyle: TextStyle(color: Colors.black54),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black54),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF3E2723)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        style: TextStyle(color: Colors.black),
                      ),
                      SizedBox(height: 12),
                      TextField(
                        controller: capacidadController,
                        decoration: InputDecoration(
                          labelText: 'Capacidad',
                          labelStyle: TextStyle(color: Colors.black54),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black54),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF3E2723)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF3E2723),
                            padding: EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            final nombre = nombreController.text.trim();
                            final capacidadText =
                                capacidadController.text.trim();
                            if (nombre.isEmpty || capacidadText.isEmpty) {
                              Get.snackbar(
                                'Error',
                                'Nombre y Capacidad son obligatorios',
                                backgroundColor: Colors.red.shade100,
                                colorText: Colors.red,
                              );
                              return;
                            }
                            final capacidad = int.tryParse(capacidadText);
                            if (capacidad == null) {
                              Get.snackbar(
                                'Error',
                                'Capacidad debe ser un número',
                                backgroundColor: Colors.red.shade100,
                                colorText: Colors.red,
                              );
                              return;
                            }
                            controller.editarMesa(
                              MesaModel(
                                numero: mesa.numero,
                                id: mesa.id,
                                nombre: nombre,
                                capacidad: capacidad,
                                ocupada:
                                    false, // Por defecto, ocupada será falsa
                              ),
                            );
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Actualizar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
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
    builder:
        (context) => StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                backgroundColor: Color(0xFFF2F2F2), // Fondo más suave y sólido
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  color: Color(0xFF3E2723), // Color de fondo del encabezado
                  child: Text(
                    'Agregar Platillo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                content: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nombreController,
                          decoration: InputDecoration(
                            labelText: 'Nombre',
                            labelStyle: TextStyle(color: Colors.black54),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black54),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF3E2723)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          style: TextStyle(color: Colors.black),
                        ),
                        SizedBox(height: 12),
                        TextField(
                          controller: precioController,
                          decoration: InputDecoration(
                            labelText: 'Precio',
                            labelStyle: TextStyle(color: Colors.black54),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black54),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF3E2723)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: Colors.black),
                        ),
                        SizedBox(height: 12),
                        Obx(
                          () => DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Categoría',
                              labelStyle: TextStyle(color: Colors.black54),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black54),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF3E2723),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            value: selectedCategoria,
                            items:
                                controller.categorias
                                    .map(
                                      (categoria) => DropdownMenuItem(
                                        value: categoria.nombre,
                                        child: Text(categoria.nombre),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCategoria = value;
                                selectedSubcategoria = null;
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 12),
                        if (selectedCategoria != null)
                          Obx(() {
                            final categoria = controller.categorias.firstWhere(
                              (c) => c.nombre == selectedCategoria,
                              orElse:
                                  () => CategoriaModel(
                                    nombre: '',
                                    subcategorias: [],
                                  ),
                            );
                            return DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Subcategoría',
                                labelStyle: TextStyle(color: Colors.black54),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black54),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF3E2723),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              value: selectedSubcategoria,
                              items:
                                  categoria.subcategorias
                                      .map(
                                        (sub) => DropdownMenuItem(
                                          value: sub,
                                          child: Text(sub),
                                        ),
                                      )
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
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF3E2723),
                            padding: EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            final nombre = nombreController.text.trim();
                            final precio = double.tryParse(
                              precioController.text.trim(),
                            );
                            if (nombre.isEmpty ||
                                precio == null ||
                                selectedCategoria == null ||
                                selectedSubcategoria == null) {
                              Get.snackbar(
                                'Error',
                                'Todos los campos son obligatorios',
                                backgroundColor: Colors.red.shade100,
                                colorText: Colors.red,
                              );
                              return;
                            }
                            controller.agregarPlatillo(
                              PlatilloModel(
                                nombre: nombre,
                                precio: precio,
                                categoria: selectedCategoria!,
                                subcategoria: selectedSubcategoria!,
                              ),
                            );
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Agregar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        ),
  );
}

void showEditPlatilloDialog(
  BuildContext context,
  GerenteController controller,
  PlatilloModel platillo,
) {
  final nombreController = TextEditingController(text: platillo.nombre);
  final precioController = TextEditingController(
    text: platillo.precio.toString(),
  );
  String? selectedCategoria = platillo.categoria;
  String? selectedSubcategoria = platillo.subcategoria;

  showDialog(
    context: context,
    builder:
        (context) => StatefulBuilder(
          builder:
              (context, setState) => AlertDialog(
                backgroundColor: Color(0xFFF2F2F2), // Fondo más suave y sólido
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  color: Color(0xFF3E2723), // Color de fondo del encabezado
                  child: Text(
                    'Editar Platillo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                content: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nombreController,
                          decoration: InputDecoration(
                            labelText: 'Nombre',
                            labelStyle: TextStyle(color: Colors.black54),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black54),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF3E2723)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          style: TextStyle(color: Colors.black),
                        ),
                        SizedBox(height: 12),
                        TextField(
                          controller: precioController,
                          decoration: InputDecoration(
                            labelText: 'Precio',
                            labelStyle: TextStyle(color: Colors.black54),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black54),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF3E2723)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: Colors.black),
                        ),
                        SizedBox(height: 12),
                        Obx(
                          () => DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Categoría',
                              labelStyle: TextStyle(color: Colors.black54),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black54),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF3E2723),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            value: selectedCategoria,
                            items:
                                controller.categorias
                                    .map(
                                      (categoria) => DropdownMenuItem(
                                        value: categoria.nombre,
                                        child: Text(categoria.nombre),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedCategoria = value;
                                selectedSubcategoria = null;
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 12),
                        if (selectedCategoria != null)
                          Obx(() {
                            final categoria = controller.categorias.firstWhere(
                              (c) => c.nombre == selectedCategoria,
                              orElse:
                                  () => CategoriaModel(
                                    nombre: '',
                                    subcategorias: [],
                                  ),
                            );
                            return DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Subcategoría',
                                labelStyle: TextStyle(color: Colors.black54),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black54),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Color(0xFF3E2723),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              value: selectedSubcategoria,
                              items:
                                  categoria.subcategorias
                                      .map(
                                        (sub) => DropdownMenuItem(
                                          value: sub,
                                          child: Text(sub),
                                        ),
                                      )
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
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF3E2723),
                            padding: EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            final nombre = nombreController.text.trim();
                            final precio = double.tryParse(
                              precioController.text.trim(),
                            );
                            if (nombre.isEmpty ||
                                precio == null ||
                                selectedCategoria == null ||
                                selectedSubcategoria == null) {
                              Get.snackbar(
                                'Error',
                                'Todos los campos son obligatorios',
                                backgroundColor: Colors.red.shade100,
                                colorText: Colors.red,
                              );
                              return;
                            }
                            controller.editarPlatillo(
                              PlatilloModel(
                                id: platillo.id,
                                nombre: nombre,
                                precio: precio,
                                categoria: selectedCategoria!,
                                subcategoria: selectedSubcategoria!,
                              ),
                            );
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Actualizar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        ),
  );
}

void showAddCategoriaDialog(
  BuildContext context,
  GerenteController controller,
) {
  final nombreController = TextEditingController();
  final subcategoria1Controller = TextEditingController();
  final subcategoria2Controller = TextEditingController();

  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          backgroundColor: Color(0xFFF2F2F2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            color: Color(0xFF3E2723),
            child: Text(
              'Agregar Categoría',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nombreController,
                    decoration: InputDecoration(
                      labelText: 'Nombre de la Categoría',
                      labelStyle: TextStyle(color: Colors.black54),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black54),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF3E2723)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: subcategoria1Controller,
                    decoration: InputDecoration(
                      labelText: 'Subcategoría 1',
                      labelStyle: TextStyle(color: Colors.black54),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black54),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF3E2723)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: subcategoria2Controller,
                    decoration: InputDecoration(
                      labelText: 'Subcategoría 2',
                      labelStyle: TextStyle(color: Colors.black54),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black54),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF3E2723)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3E2723),
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      final nombre = nombreController.text.trim();
                      final subcategoria1 = subcategoria1Controller.text.trim();
                      final subcategoria2 = subcategoria2Controller.text.trim();

                      if (nombre.isEmpty ||
                          subcategoria1.isEmpty ||
                          subcategoria2.isEmpty) {
                        Get.snackbar(
                          'Error',
                          'Todos los campos son obligatorios',
                          backgroundColor: Colors.red.shade100,
                          colorText: Colors.red,
                        );
                        return;
                      }

                      controller.agregarCategoria(
                        CategoriaModel(
                          nombre: nombre,
                          subcategorias: [subcategoria1, subcategoria2],
                        ),
                      );
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Agregar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
  );
}

void showEditCategoriaDialog(
  BuildContext context,
  GerenteController controller,
  CategoriaModel categoria,
) {
  final subcategoria1Controller = TextEditingController(
    text: categoria.subcategorias.isNotEmpty ? categoria.subcategorias[0] : '',
  );
  final subcategoria2Controller = TextEditingController(
    text: categoria.subcategorias.length > 1 ? categoria.subcategorias[1] : '',
  );

  showDialog(
    context: context,
    builder:
        (context) => AlertDialog(
          backgroundColor: Color(0xFFF2F2F2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Container(
            padding: EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            color: Color(0xFF3E2723),
            child: Text(
              'Editar Categoría',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: subcategoria1Controller,
                    decoration: InputDecoration(
                      labelText: 'Subcategoría 1',
                      labelStyle: TextStyle(color: Colors.black54),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black54),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF3E2723)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: subcategoria2Controller,
                    decoration: InputDecoration(
                      labelText: 'Subcategoría 2',
                      labelStyle: TextStyle(color: Colors.black54),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black54),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF3E2723)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3E2723),
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      final subcategoria1 = subcategoria1Controller.text.trim();
                      final subcategoria2 = subcategoria2Controller.text.trim();

                      if (subcategoria1.isEmpty || subcategoria2.isEmpty) {
                        Get.snackbar(
                          'Error',
                          'Ambas subcategorías son obligatorias',
                          backgroundColor: Colors.red.shade100,
                          colorText: Colors.red,
                        );
                        return;
                      }

                      controller.editarCategoria(
                        CategoriaModel(
                          nombre: categoria.nombre,
                          subcategorias: [subcategoria1, subcategoria2],
                        ),
                      );
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Actualizar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
  );
}
