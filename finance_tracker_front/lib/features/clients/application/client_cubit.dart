import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../models/client.dart';
import '../data/client_repository.dart';

// Estados
abstract class ClientState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ClientInitial extends ClientState {}
class ClientLoading extends ClientState {}
class ClientSuccess extends ClientState {
  final List<Client> clients;
  ClientSuccess(this.clients);

  @override
  List<Object?> get props => [clients];
}
class ClientFailure extends ClientState {
  final String message;
  ClientFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class ClientCubit extends Cubit<ClientState> {
  final ClientRepository repository;

  ClientCubit(this.repository) : super(ClientInitial());

  Future<void> loadClients(String token) async {
    try {
      emit(ClientLoading());
      final clients = await repository.fetchClients(token);
      emit(ClientSuccess(clients));
    } catch (e) {
      emit(ClientFailure(e.toString()));
    }
  }

  Future<void> createClient(String token, Map<String, dynamic> clientData) async {
    try {
      emit(ClientLoading());
      await repository.createClient(token, clientData);
      await loadClients(token);
    } catch (e) {
      emit(ClientFailure(e.toString()));
    }
  }
}
