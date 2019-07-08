import 'package:flutter/material.dart';
import 'package:wanandroid_flutter/entity/todo_entity.dart';
import 'package:wanandroid_flutter/http/index.dart';
import 'package:wanandroid_flutter/res/index.dart';
import 'package:wanandroid_flutter/utils/index.dart';

///to-do 列表页
class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<Datas> datas;

  @override
  void initState() {
    super.initState();
    _getTodoList();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        color: WColors.theme_color,
        //todo 重构为AnimatedList实现动画增减item
        child: ListView.builder(
          physics: BouncingScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            if (datas == null || datas.length == 0) {
              return Container(
                height: pt(400),
                alignment: Alignment.center,
                child: Text(
                  res.allEmpty,
                  style: TextStyle(fontSize: 18),
                ),
              );
            } else {
              return TodoItem(index, datas[index]);
            }
          },
          itemCount: datas == null ? 1 : datas.length,
        ),
        onRefresh: _refresh);
  }

  Future<void> _refresh() async {
    //todo 刷新
    await _getTodoList();
  }

  ///获取todo列表
  ///todo  增加过滤条件
  Future _getTodoList() async {
    try {
      Response response = await TodoApi.getTodoList(1);
      TodoEntity entity = TodoEntity.fromJson(response.data);
      datas = entity.data.datas;
      print('_TodoListPageState : 获取todo列表成功');
    } catch (e) {
      DisplayUtil.showMsg(context, exception: e);
    }
    if (mounted) {
      setState(() {});
    }
  }
}

class TodoItem extends StatefulWidget {
  int index;
  Datas data;

  TodoItem(this.index, this.data);

  @override
  _TodoItemState createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: pt(65),
      margin: EdgeInsets.only(top: widget.index == 0 ? pt(20) : 0),
      child: Stack(
        overflow: Overflow.visible,
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            left: widget.data.status == 1 ? null : -pt(45 / 2.0 + 60),
            //一个圆角半径+日期widget的长度
            right: widget.data.status == 1 ? -pt(45 / 2.0 + 60) : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: pt(50),
                  margin: EdgeInsets.only(right: pt(10)),
                  child: Text(
                    widget.data.dateStr,
                    maxLines: 1,
                    style: TextStyle(fontSize: 10, color: WColors.hint_color),
                  ),
                ),
                Container(
                  //一个疑问：一旦给contatiner加上alignment后，它的宽就固定为maxWidth了，这不是我想要的，所以目前只好给他的child再套上一个stack来实现内容垂直居中
                  constraints: BoxConstraints(
                    maxWidth: pt(375 - 50.0), //屏幕宽 - 日期widget长度
                    minWidth: pt(375 / 2.0 + 45 / 2.0), //一半屏幕宽 + 一个圆角半径
                    maxHeight: pt(45),
                    minHeight: pt(45),
                  ),
                  decoration: ShapeDecoration(
                    color: widget.data.status == 1
                        ? WColors.theme_color_light
                        : WColors.theme_color_dark,
                    shadows: <BoxShadow>[
                      DisplayUtil.supreLightElevation(
                        baseColor: widget.data.status == 1
                            ? WColors.theme_color_light.withAlpha(0xaa)
                            : WColors.theme_color_dark.withAlpha(0xaa),
                      ),
                    ],
                    shape: StadiumBorder(),
                  ),
//                  padding: EdgeInsets.symmetric(
//                    horizontal: pt(45 / 2.0 + 10),
//                  ),
                  child: Stack(
                    alignment: widget.data.status == 1
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: pt(45 / 2.0 + 5),
                        ),
                        child: Text(
                          widget.data.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white, fontSize: 17),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        child: RotatedBox(
                          child: Image.asset(
                            'images/pull.png',
                            width: pt(20),
                            height: pt(20),
                            color: Colors.white30,
                          ),
                          quarterTurns: 3,
                        ),
                      ),
                      Positioned(
                        left: 0,
                        child: RotatedBox(
                          child: Image.asset(
                            'images/pull.png',
                            width: pt(20),
                            height: pt(20),
                            color: Colors.white30,
                          ),
                          quarterTurns: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: pt(50),
                  margin: EdgeInsets.only(left: pt(10)),
                  child: Text(
                    widget.data.dateStr,
                    maxLines: 1,
                    style: TextStyle(fontSize: 10, color: WColors.hint_color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
