import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_ordering_web_1/bloc/get_all_bloc/get_all_bloc.dart';
import 'package:food_ordering_web_1/repo/admin_repo.dart';

import '../widgets/admin_page.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetAllBlocBloc, GetAllBlocState>(
      bloc: GetAllBlocBloc(restaurantId: 'Restaurant A')
        ..add(GetAllBlocCreation()),
      builder: (context, state) {
        if (state is GetAllBlocLoading) {
          return CircularProgressIndicator();
        } else if (state is GetAllBlocSuccess) {
          return AdminPage(
            allOrders: state.allOrders,
          );
        } else if (state is GetAllBlocFail) {
          return Container(
            child: Text(state.message),
          );
        } else {
          return SizedBox();
        }
      },
    );
  }
}
