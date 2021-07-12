import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'api.dart';

class SupportPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SupportPageState();
  }
}

class _SupportPageState extends State<SupportPage> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController controller = TextEditingController();
    return Scaffold(
        appBar: AppBar(
          title: Text('Поддержка'),
          actions: [
            Material(
                color: Colors.transparent,
                child: InkWell(
                    onTap: () => FakeApi().support(
                        email: emailController.value.text,
                        text: controller.value.text),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Icon(Icons.check),
                    )))
          ],
        ),
        body: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: DropdownButton(items: [
                DropdownMenuItem(
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width - 25,
                        child: Text('Проблемы с доставкой')),
                    value: 'delivery'),
                DropdownMenuItem(
                    child: Text('Технические проблемы'), value: 'tech')
              ], onChanged: (value) => null),
            ),
            TextField(
                decoration: InputDecoration(hintText: 'Email'),
                controller: emailController),
            TextField(maxLines: null, controller: controller)
          ],
        ));
  }
}
