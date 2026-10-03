import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ContactosProvider(),
      child: const MiAgendaApp(),
    ),
  );
}

class MiAgendaApp extends StatelessWidget {
  const MiAgendaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Agenda',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (_) => const LoginScreen(),
        '/contactos': (_) => const ContactosScreen(),
        '/agregar': (_) => const AgregarContactoScreen(),
      },
    );
  }
}


class Contacto {
  final String nombre;
  final String apellido;
  final String telefono;
  final String email;
  final String domicilio;
  final DateTime? fechaNacimiento;
  final String genero;

  Contacto({
    required this.nombre,
    required this.apellido,
    required this.telefono,
    required this.email,
    required this.domicilio,
    required this.fechaNacimiento,
    required this.genero,
  });

  String get nombreCompleto => '$nombre $apellido';
}

class ContactosProvider extends ChangeNotifier {
  final List<Contacto> _contactos = [];

  List<Contacto> get contactos => List.unmodifiable(_contactos);

  void agregar(Contacto c) {
    _contactos.add(c);
    notifyListeners();
  }

  List<Contacto> filtrar(String texto) {
    final q = texto.trim().toLowerCase();
    if (q.isEmpty) return contactos;
    return _contactos
        .where((c) =>
            c.nombreCompleto.toLowerCase().contains(q) ||
            c.telefono.contains(q))
        .toList();
  }
}


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  static const _usuarioValido = 'admin@agenda.com';
  static const _passValida = '1234';

  void _iniciarSesion() {
    if (!_formKey.currentState!.validate()) return;
    if (_usuarioCtrl.text.trim() == _usuarioValido &&
        _passCtrl.text == _passValida) {
      Navigator.pushReplacementNamed(context, '/contactos');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario o contraseña incorrectos')),
      );
    }
  }

  @override
  void dispose() {
    _usuarioCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.account_circle, size: 96, color: Colors.blue),
                  const SizedBox(height: 8),
                  const Text('Mi Agenda',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, color: Colors.blue)),
                  const SizedBox(height: 32),
                  const Text('Usuario'),
                  TextFormField(
                    controller: _usuarioCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                        hintText: 'Ingrese email', border: OutlineInputBorder()),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Ingrese el usuario' : null,
                  ),
                  const SizedBox(height: 16),
                  const Text('Contraseña'),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                        hintText: 'Ingrese password', border: OutlineInputBorder()),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Ingrese la contraseña' : null,
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: _iniciarSesion,
                    child: const Text('Iniciar sesión'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class ContactosScreen extends StatefulWidget {
  const ContactosScreen({super.key});

  @override
  State<ContactosScreen> createState() => _ContactosScreenState();
}

class _ContactosScreenState extends State<ContactosScreen> {
  bool _buscando = false;
  final _busquedaCtrl = TextEditingController();

  void _cerrarBusqueda() {
    setState(() {
      _buscando = false;
      _busquedaCtrl.clear();
    });
  }

  @override
  void dispose() {
    _busquedaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contactos = context.watch<ContactosProvider>().filtrar(_busquedaCtrl.text);

    return Scaffold(
      appBar: AppBar(
        leading: _buscando
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _cerrarBusqueda)
            : null,
        title: _buscando
            ? TextField(
                controller: _busquedaCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                    hintText: 'Buscar...', border: InputBorder.none),
                onChanged: (_) => setState(() {}),
              )
            : const Text('Contactos'),
        actions: [
          if (_buscando)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(_busquedaCtrl.clear),
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => setState(() => _buscando = true),
            ),
          PopupMenuButton<String>(
            onSelected: (_) => Navigator.pushReplacementNamed(context, '/'),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'salir', child: Text('Cerrar sesión')),
            ],
          ),
        ],
      ),
      body: contactos.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(_buscando ? 'Sin resultados' : 'Aún no tienes contactos',
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: contactos.length,
              itemBuilder: (_, i) {
                final c = contactos[i];
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(c.nombreCompleto,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(c.telefono),
                  trailing: const Icon(Icons.phone, color: Colors.green),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/agregar'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AgregarContactoScreen extends StatefulWidget {
  const AgregarContactoScreen({super.key});

  @override
  State<AgregarContactoScreen> createState() => _AgregarContactoScreenState();
}

class _AgregarContactoScreenState extends State<AgregarContactoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController(text: '+54 ');
  final _emailCtrl = TextEditingController();
  final _domicilioCtrl = TextEditingController();
  DateTime? _fechaNacimiento;
  String _genero = 'Femenino';

  Future<void> _elegirFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (fecha != null) setState(() => _fechaNacimiento = fecha);
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ContactosProvider>().agregar(Contacto(
          nombre: _nombreCtrl.text.trim(),
          apellido: _apellidoCtrl.text.trim(),
          telefono: _telefonoCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          domicilio: _domicilioCtrl.text.trim(),
          fechaNacimiento: _fechaNacimiento,
          genero: _genero,
        ));
    Navigator.pop(context);
  }

  @override
  void dispose() {
    for (final c in [_nombreCtrl, _apellidoCtrl, _telefonoCtrl, _emailCtrl, _domicilioCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _campo(String label, TextEditingController ctrl, String hint,
      {TextInputType? tipo, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          TextFormField(
            controller: ctrl,
            keyboardType: tipo,
            decoration: InputDecoration(hintText: hint, border: const OutlineInputBorder()),
            validator: validator,
          ),
        ],
      ),
    );
  }

  String? _requerido(String? v) => (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null;

  @override
  Widget build(BuildContext context) {
    final fechaTexto = _fechaNacimiento == null
        ? 'Seleccionar fecha'
        : '${_fechaNacimiento!.day}/${_fechaNacimiento!.month}/${_fechaNacimiento!.year}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar'),
        actions: [IconButton(icon: const Icon(Icons.check), onPressed: _guardar)],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _campo('Nombre', _nombreCtrl, 'Ingrese nombre', validator: _requerido),
            _campo('Apellido', _apellidoCtrl, 'Ingrese apellido', validator: _requerido),
            _campo('Número de teléfono', _telefonoCtrl, '+54 __ ___ __ __',
                tipo: TextInputType.phone, validator: _requerido),
            _campo('Correo electrónico', _emailCtrl, 'Ingrese email',
                tipo: TextInputType.emailAddress,
                validator: (v) => (v != null && v.isNotEmpty && !v.contains('@'))
                    ? 'Email inválido'
                    : null),
            _campo('Domicilio', _domicilioCtrl, 'Ingrese domicilio'),
            const Text('Fecha de nacimiento'),
            OutlinedButton.icon(
              onPressed: _elegirFecha,
              icon: const Icon(Icons.calendar_today),
              label: Text(fechaTexto),
            ),
            const SizedBox(height: 16),
            const Text('Género'),
            for (final g in ['Femenino', 'Masculino'])
              RadioListTile<String>(
                title: Text(g),
                value: g,
                groupValue: _genero,
                onChanged: (v) => setState(() => _genero = v!),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
          ],
        ),
      ),
    );
  }
}
