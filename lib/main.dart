import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Classe que representa um Clã de Naruto.
class Clan {
  final String id;
  final String name;
  final List<String> characters;

  Clan({required this.id, required this.name, required this.characters});

  factory Clan.fromJson(Map<String, dynamic> json) {
    final id = json['id'].toString();
    final name = (json['name'] as String?) ?? 'Nome Desconhecido';
    final characters =
        (json['characters'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    return Clan(id: id, name: name, characters: characters);
  }
}

Future<List<Clan>> fetchClans() async {
  final response = await http.get(
    Uri.parse('https://dattebayo-api.onrender.com/clans'),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> responseBody =
        jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> jsonList = responseBody['clans'] as List<dynamic>;
    return jsonList
        .map((json) => Clan.fromJson(json as Map<String, dynamic>))
        .toList();
  } else {
    throw Exception(
      'Falha ao carregar os clãs. Código de status: ${response.statusCode}',
    );
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<Clan>> futureClans;

  @override
  void initState() {
    super.initState();
    futureClans = fetchClans();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clãs de Naruto',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Clãs de Naruto'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Center(
          child: FutureBuilder<List<Clan>>(
            future: futureClans,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final clan = snapshot.data![index];
                    return InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder:
                              (_) => AlertDialog(
                                title: const Text('Detalhes do Clã'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('ID: ${clan.id}'),
                                    const SizedBox(height: 8),
                                    Text('Nome: ${clan.name}'),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Total de personagens: ${clan.characters.length}',
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Personagens:'),
                                    ...clan.characters.map(
                                      (char) => Text('- $char'),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text('Fechar'),
                                    onPressed:
                                        () => Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                clan.name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Personagens:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              ...clan.characters.map(
                                (charName) => Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8.0,
                                    top: 4.0,
                                  ),
                                  child: Text(
                                    '- $charName',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ),
                              ),
                              if (clan.characters.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8.0,
                                    top: 4.0,
                                  ),
                                  child: Text(
                                    'Nenhum personagem listado.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Text(
                  'Erro: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                );
              }

              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
