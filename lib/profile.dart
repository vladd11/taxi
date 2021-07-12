import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:taxi/api.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProfilePageState();
  }
}

class _ProfilePageState extends State<ProfilePage> {
  Api api = FakeApi();
  Profile profile;

  @override
  void initState() {
    super.initState();
    update();
  }

  void update() async {
    Profile _profile = await api.getProfile();
    setState(() => profile = _profile);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle caption = Theme.of(context).textTheme.caption;
    return Scaffold(
      appBar: AppBar(title: Text('Профиль')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () {
            return Future.delayed(Duration(seconds: 3));
          },
          child: ListView(children: [
            Row(
              children: [
                CachedNetworkImage(
                    imageUrl: 'https://logo.clearbit.com/google.com?size=64'),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text('Name'),
                )
              ],
            ),
            Text(
              'Заказы',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            Divider(),
            ListView.builder(
                shrinkWrap: true,
                itemCount: (profile == null) ? 0 : profile.orders.length,
                itemBuilder: (context, index) {
                  Order order = profile.orders[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Stack(
                      children: [
                        Card(
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CachedNetworkImage(imageUrl: order.product.imageUrl),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 1),
                                      child: Text('Название:'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 1),
                                      child: Text('Адрес:'),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 1),
                                      child: Text('Статус заказа:'),
                                    ),
                                    Text('Цена:'),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 2),
                                      child: Text(order.product.name, style: caption),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 2),
                                      child: Text(order.streetName, style: caption),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 2),
                                      child: Text(order.statusAsString(), style: caption),
                                    ),
                                    Text(order.price.toString(), style: caption),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                })
          ]),
        ),
      ),
    );
  }
}
