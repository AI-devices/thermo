import 'package:flutter/material.dart';
import 'package:thermo/components/helper.dart';
import 'package:thermo/widgets/assets.dart';

class FaqWidget extends StatelessWidget {
  const FaqWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
      children: [
        const Center(child: Text('Справка', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
        const SizedBox(height: 20),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(Icons.keyboard_arrow_up),
            SizedBox(width: 15),
            Expanded(child: Text('Температура растет, но рост замедляется.'))
          ],
        ),
        const SizedBox(height: 20),
        const Row(
          children: [
            Icon(Icons.keyboard_double_arrow_up),
            SizedBox(width: 15),
            Expanded(child: Text('Температура растет и рост ускоряется.'))
          ],
        ),
        const SizedBox(height: 20),
        const Row(
          children: [
            Icon(Icons.keyboard_arrow_down),
            SizedBox(width: 15),
            Expanded(child: Text('Температура падает, но падение замедляется.'))
          ],
        ),
        const SizedBox(height: 20),
        const Row(
          children: [
            Icon(Icons.keyboard_double_arrow_down),
            SizedBox(width: 15),
            Expanded(child: Text('Температура падает и падение ускоряется.'))
          ],
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 3),
          child: Row(
            children: [
              SizedBox(
                width: 19,
                child: AppAssets.iconDelta
              ),
              const SizedBox(width: 15),
              const Expanded(child: Text('${Helper.celsius}/мин'))
            ],
          ),
        ),
        const SizedBox(height: 5),
        const Divider(color: Colors.black),

      ],
    );
  }
}