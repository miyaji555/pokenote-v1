import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:poke_scouter/constants/route_path.dart';
import 'package:poke_scouter/presentation/Widget/my_page_widget.dart';
import 'package:poke_scouter/presentation/login/user_state_provider.dart';

import '../../providers/auth_controller.dart';

class MyPage extends ConsumerWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userStateProvider);
    return Scaffold(
        appBar: AppBar(
          title: const Text(kPageNameMy),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 8,
            ),
            userState.when(
              data: (data) {
                // ログイン済みの場合
                if (data != null) {
                  return MyPageTile(
                      title: 'ログアウト',
                      icons: Icons.logout,
                      iconColor: Colors.grey,
                      onTap: () {
                        ref.read(authControllerProvider.notifier).signOut();
                      });
                }
                // 未ログインの場合
                return MyPageTile(
                    title: 'ログイン・新規会員登録',
                    icons: Icons.login,
                    iconColor: Colors.grey,
                    onTap: () {
                      context.push(kPagePathLogin);
                    });
              },
              error: (_, __) {
                return const Scaffold(
                  body: Center(
                    child: Text('エラーだよ'),
                  ),
                );
              },
              loading: () {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
            MyPageTile(
                title: 'ダークモード',
                icons: Icons.add,
                iconColor: Colors.grey,
                onTap: () {}),
            MyPageTile(
                title: 'パーティ登録',
                icons: Icons.add,
                iconColor: Colors.grey,
                onTap: () {}),
          ],
        ));
  }
}