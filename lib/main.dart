import 'dart:async'; 

import 'dart:convert'; 

import 'package:flutter/material.dart'; 

import 'package:http/http.dart' as http; 

 

// A classe Character NÃO É MAIS NECESSÁRIA se a lista de personagens for de strings ou ints simples. 

// class Character { ... } 

 

/// Classe que representa um Clã de Naruto. 

/// Agora contém ID, nome e uma lista de Strings para os personagens. 

class Clan { 

  final String id; 

  final String name; 

  final List<String> characters; // <<< VOLTOU A SER UMA LISTA DE STRINGS 

 

  Clan({required this.id, required this.name, required this.characters}); 

 

  /// Construtor de fábrica para criar uma instância de Clan a partir de um JSON. 

  factory Clan.fromJson(Map<String, dynamic> json) { 

    // Garante que 'id' é uma String. 

    final id = json['id'].toString(); 

 

    // Tenta obter o nome, com fallback para "Nome Desconhecido". 

    final name = (json['name'] as String?) ?? 'Nome Desconhecido'; 

 

    // Processa a lista de 'characters'. 

    // 1. Tenta obter 'characters' como uma List<dynamic>. Se for nulo, usa uma lista vazia. 

    // 2. Mapeia CADA ITEM DA LISTA PARA UMA STRING USANDO .toString(). 

    //    Isso vai converter ints (123 -> "123") ou strings ("Naruto" -> "Naruto"). 

    // 3. Converte o resultado para uma List<String>. 

    final characters = 

        (json['characters'] as List<dynamic>?) 

            ?.map( 

              (e) => e.toString(), 

            ) // <<< MUDANÇA AQUI: CONVERTE PARA STRING DIRETAMENTE 

            .toList() ?? 

        []; 

 

    return Clan(id: id, name: name, characters: characters); 

  } 

} 

 

/// Função assíncrona para buscar a lista de clãs da API. 

/// Espera que a resposta seja um MAPA com a chave "clans". 

Future<List<Clan>> fetchClans() async { 

  final response = await http.get( 

    Uri.parse('https://dattebayo-api.onrender.com/clans'), 

  ); 

 

  if (response.statusCode == 200) { 

    // Primeiro, decodifica o corpo da resposta como um Map<String, dynamic> 

    final Map<String, dynamic> responseBody = 

        jsonDecode(response.body) as Map<String, dynamic>; 

 

    // Agora, acessa a lista de clãs usando a chave "clans" 

    // Esta linha causou o erro `int is not subtype of Map` antes, 

    // se o item dentro de 'clans' não fosse um Map, mas sim um int. 

 

    final List<dynamic> jsonList = responseBody['clans'] as List<dynamic>; 

 

    // Converte cada objeto JSON (que representa um clã) em uma instância de Clan. 

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

                    return Card( 

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

                            // Exibe a lista de personagens, que agora são Strings diretas 

                            ...clan.characters.map( 

                              (charName) => Padding( 

                                padding: const EdgeInsets.only( 

                                  left: 8.0, 

                                  top: 4.0, 

                                ), 

                                child: Text( 

                                  '- $charName', // <<< ACESSANDO A STRING DIRETAMENTE 

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

 

 