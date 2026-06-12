import 'package:flutter/material.dart';

class LoginFormProvider extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();

  late TabController _tabController;
  TabController get tabController => _tabController;

  bool _isLogin = true;
  bool get isLogin => _isLogin;

  // We need to initialize the TabController with a TickerProvider
  void initTabController(TickerProvider vsync) {
    _tabController = TabController(length: 2, vsync: vsync);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _isLogin = _tabController.index == 0;
        notifyListeners();
      }
    });
  }

  bool _isRememberMe = false;
  bool get isRememberMe => _isRememberMe;

  void toggleRememberMe(bool value) {
    _isRememberMe = value;
    notifyListeners();
  }

  void toggleMode(int index) {
    _tabController.animateTo(index);
    _isLogin = index == 0;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}
