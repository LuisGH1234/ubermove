import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ubermove/common/constants/colors.dart';
import 'package:ubermove/presentation/blocs/user/user.bloc.dart';
import 'package:ubermove/presentation/widgets/button.dart';

class PaymentTMethodList extends StatefulWidget {
  static const PATH = "/paymentTMethodList";

  @override
  State<StatefulWidget> createState() => _PaymentTMethodListState();
}

class _PaymentTMethodListState extends State<PaymentTMethodList> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _pmID = 0;

  @override
  void initState() {
    super.initState();
    context.bloc<UserBloc>().getMyPaymentMethods();
  }

  void showSnackbarError(String message) {
    final snackbar = SnackBar(
      content: Text(message),
      backgroundColor: $Colors.ACCENT_RED,
    );
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text('Metodos de Pago')),
      backgroundColor: $Colors.BACKGROUD,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: BlocConsumer<UserBloc, UserState>(
            listener: (context, state) {
              if (state.paymentMethodList.loading) return;
              if (state.paymentMethodList.error) {
                showSnackbarError(state.paymentMethodList.message);
              }
            },
            builder: (context, state) {
              if (state.paymentMethodList.loading) {
                return Center(child: CircularProgressIndicator());
              } else if (state.paymentMethodList.error == true) {
                return Center(
                  child: Text(
                      "Lo sentimos ocurrio un problema: ${state.paymentMethodList.message}"),
                );
              }
              return Column(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: state.paymentMethodList.data.map((e) {
                        return RadioListTile<int>(
                            subtitle: Text("Pago antes de iniciar"),
                            secondary: Icon(Icons.monetization_on),
                            title: Text(e.description),
                            value: e.id,
                            groupValue: _pmID,
                            onChanged: (value) {
                              setState(() {
                                _pmID = value;
                              });
                            });
                      }).toList(),
                    ),
                  ),
                  Button("Continuar", onPressed: () {
                    Navigator.popUntil(context, ModalRoute.withName('/'));
                  }),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
