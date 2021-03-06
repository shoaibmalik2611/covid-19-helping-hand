import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:helping_hand/config/config.dart';
import 'package:helping_hand/screens/chat_screen.dart';
import 'package:helping_hand/models/user_model_for_messages.dart';

class buildChatHeads extends StatefulWidget {
  buildChatHeads(
      {@required this.postID,
      @required this.helperID,
      @required this.postOwnerID,
      this.me});

  final String postID;
  final String helperID;
  final String postOwnerID;
  final String me;

  @override
  buildChatHeadsState createState() => buildChatHeadsState();
}

class buildChatHeadsState extends State<buildChatHeads> {
  String otherPersonphotUrl =
      'https://firebasestorage.googleapis.com/v0/b/helping-hand-76970.appspot.com/o/default-user-img.png?alt=media&token=d96df74f-5b3b-4f08-86f8-d1a913459e07';
  String otherPersonName = 'loading..';
  String otherPersonID = 'loading..';
  String lastMessage = 'loading..';
  String lastMessageSender = 'loading..';
  String postName = 'loading...';
  bool lastMessageRead = false;

  Future<void> setDatas() async {
    final CollectionReference perticipents = Firestore.instance.collection(
        'messages/${widget.helperID}_${widget.postID}/perticipents');

    await for (var snapshot in perticipents.snapshots()) {
      for (var otherPerson in snapshot.documents) {
        if (otherPerson.data['id'] != widget.me) {
          setState(() {
            otherPersonName = otherPerson.data['name'];
            otherPersonID = otherPerson.data['id'];
            if (otherPerson.data['photUrl'] != "" &&
                otherPerson.data['photUrl'] != null) {
              otherPersonphotUrl = otherPerson.data['photUrl'];
            } else {
              otherPersonphotUrl =
                  'https://firebasestorage.googleapis.com/v0/b/helping-hand-76970.appspot.com/o/default-user-img.png?alt=media&token=d96df74f-5b3b-4f08-86f8-d1a913459e07';
            }
          });
          break;
        }
      }
      break;
    }

    final CollectionReference texts = Firestore.instance
        .collection('messages/${widget.helperID}_${widget.postID}/texts');

    await for (var snapshot
        in texts.orderBy('time', descending: false).snapshots()) {
      for (var text in snapshot.documents) {
        setState(() {
          lastMessage = text.data['text'];
          lastMessageSender = text.data['sender_name'];
          lastMessageRead = text.data['unread'];
        });
      }
      break;
    }

    final DocumentReference post = Firestore.instance
        .document('messages/${widget.helperID}_${widget.postID}');

    await for (var snapshot in post.snapshots()) {
      setState(() {
        postName = snapshot.data['postName'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setDatas();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: () {
              getMessages();
            },
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              //margin: EdgeInsets.only(left: 20, right: 20, bottom: 20),
              color: Colors.white,
              elevation: 6,
              child: ListTile(
                // leading: ClipRRect(
                //   borderRadius: BorderRadius.circular(15),
                //   child: Image.network(
                //     otherPersonphotUrl,
                //     width: 50,
                //     fit: BoxFit.contain,
                //   ),
                // ),
                title: Text(
                  otherPersonName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: titleTextStyle.copyWith(
                      color: primaryColor, fontSize: 16),
                ),
                subtitle: lastMessageRead? Text(
                  lastMessageSender + ": " + lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: bodyTextStyle.copyWith(
                      color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                ) : Text(
                  lastMessageSender + ": " + lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: bodyTextStyle.copyWith(
                      color: secondaryColor, fontSize: 10),
                ),
                trailing: Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: secondaryColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text(
                        postName,
                        style: bodyTextStyle.copyWith(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void getMessages() async {
    var route = new MaterialPageRoute(
        builder: (BuildContext context) => new ChatScreen(
              theOtherPerson: User(
                  id: otherPersonID,
                  imageUrl: otherPersonphotUrl,
                  name: otherPersonName),
              messageField: 'messages/${widget.helperID}_${widget.postID}',
            ));
    Navigator.of(context).push(route);
  }
}
