import '../../data/models/auth_model.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  Future<AuthModel> call({required String email, required String password}) {
    return repository.login(email: email, password: password);
  }
}
