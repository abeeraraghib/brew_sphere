import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'shared_drawer.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final TextEditingController _postController = TextEditingController();
  final Map<String, TextEditingController> _commentControllers = {};
  final Map<String, bool> _showReplies = {};

  void _submitPost() async {
    final text = _postController.text.trim();
    if (text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection('posts').add({
      'text': text,
      'author': user?.email ?? 'Anonymous',
      'uid': user?.uid,
      'timestamp': Timestamp.now(),
      'likes': 0,
    });

    _postController.clear();
    setState(() {});
  }

  void _submitComment(String postId) async {
    final controller = _commentControllers[postId];
    if (controller == null) return;

    final text = controller.text.trim();
    if (text.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .add({
      'text': text,
      'author': user?.email ?? 'Anonymous',
      'uid': user?.uid,
      'timestamp': Timestamp.now(),
    });

    controller.clear();
    setState(() {});
  }

  void _toggleLike(String postId) async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(postRef);
      final currentLikes = (snapshot['likes'] ?? 0) as int;
      transaction.update(postRef, {'likes': currentLikes + 1});
    });
  }

  void _deletePost(String postId) async {
    await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
  }

  void _editPost(String postId, String currentText) {
    final controller = TextEditingController(text: currentText);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Post'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('posts')
                  .doc(postId)
                  .update({'text': controller.text.trim()});
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  Widget _buildComments(String postId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final comments = snapshot.data!.docs;
        final showAll = _showReplies[postId] ?? false;

        final displayedComments = showAll ? comments : comments.take(3);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...displayedComments.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final commentTime =
                  timeago.format((data['timestamp'] as Timestamp).toDate());
              return Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['text'] ?? '',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
                      ),
                      Text(
                        "By ${data['author'] ?? 'Unknown'} • $commentTime",
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              );
            }),
            if (comments.length > 3)
              TextButton(
                onPressed: () =>
                    setState(() => _showReplies[postId] = !showAll),
                child: Text(
                  showAll ? 'Hide replies' : 'View more replies',
                  style: const TextStyle(color: Colors.white60),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const BrewSphereDrawer(),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.7),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white70),
        title: const Text(
          'Community',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/community.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: kToolbarHeight + 24),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _postController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "What's brewing in your mind?",
                    hintStyle: const TextStyle(color: Colors.white54),
                    fillColor: Colors.black54,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _submitPost,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final posts = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        final postData =
                            post.data() as Map<String, dynamic>;
                        final postTime = timeago.format(
                            (postData['timestamp'] as Timestamp).toDate());
                        final postId = post.id;

                        _commentControllers[postId] ??=
                            TextEditingController();

                        return Card(
                          color: Colors.black.withOpacity(0.5),
                          margin: const EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  postData['text'] ?? '',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "By ${postData['author'] ?? 'Unknown'} • $postTime",
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 12),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.thumb_up,
                                          color: Colors.white),
                                      onPressed: () => _toggleLike(postId),
                                    ),
                                    Text('${postData['likes'] ?? 0}',
                                        style: const TextStyle(
                                            color: Colors.white)),
                                    if (FirebaseAuth
                                            .instance.currentUser?.uid ==
                                        postData['uid']) ...[
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.white70),
                                        onPressed: () =>
                                            _editPost(postId, postData['text']),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.redAccent),
                                        onPressed: () => _deletePost(postId),
                                      ),
                                    ]
                                  ],
                                ),
                                _buildComments(postId),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: TextField(
                                    controller: _commentControllers[postId],
                                    style:
                                        const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      hintText: "Write a comment...",
                                      hintStyle: const TextStyle(
                                          color: Colors.white54),
                                      fillColor: Colors.black26,
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.send,
                                            color: Colors.white),
                                        onPressed: () =>
                                            _submitComment(postId),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
