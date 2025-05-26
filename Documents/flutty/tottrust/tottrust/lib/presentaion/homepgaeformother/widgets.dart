// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class tottrustCard extends StatefulWidget {
  final String name;
  final int i;
  final String img;
  bool isFavorite;
  bool isSaved;
  bool isOnline;
  Future<void> Function()? onTaplike;
  Future<void> Function()? onTapsave;
  Future<void> Function()? onTapadd;
  Future<void> Function()? onTapmess;
  Future<void> Function()? onTapedit;
  tottrustCard({
    Key? key,
    required this.name,
    required this.i,
    required this.img,
    required this.isFavorite,
    required this.isSaved,
    required this.isOnline,
    this.onTaplike,
    this.onTapsave,
    this.onTapadd,
    this.onTapmess,
    this.onTapedit,
  }) : super(key: key);

  @override
  State<tottrustCard> createState() => _tottrustCardState();
}

class _tottrustCardState extends State<tottrustCard> {
  bool _isLoadingFavorite = false;
  bool _isLoadingSave = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTapedit,
      child: SizedBox(
        height: 300,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Color(0xFFEFDDED), width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: widget.img.startsWith('http')
                      ? Image.network(
                          widget.img,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            print('Error loading image: $error');
                            return Image.asset(
                              'assets/images/girl1.png',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: Color(0xFF508CD4),
                              ),
                            );
                          },
                        )
                      : Image.asset(
                          widget.img,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Text(
                widget.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                "I'm Babysitting for ${widget.i} years!",
                style: const TextStyle(fontSize: 12, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star,
                    size: 16,
                    color: index < widget.i ? Colors.amber : Colors.grey[300],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: _isLoadingSave
                        ? null
                        : () async {
                            setState(() {
                              _isLoadingSave = true;
                            });
                            try {
                              if (widget.onTapsave != null) {
                                await widget.onTapsave!();
                                setState(() {
                                  widget.isSaved = !widget.isSaved;
                                });
                              }
                            } finally {
                              setState(() {
                                _isLoadingSave = false;
                              });
                            }
                          },
                    child: _isLoadingSave
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.red),
                            ),
                          )
                        : Icon(
                            Icons.bookmark,
                            size: 20,
                            color: widget.isSaved ? Colors.red : Colors.grey,
                          ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _isLoadingSave
                        ? null
                        : () async {
                            setState(() {
                              _isLoadingSave = true;
                            });
                            try {
                              if (widget.onTapmess != null) {
                                await widget.onTapmess!();
                                setState(() {
                                  widget.isSaved = !widget.isSaved;
                                });
                              }
                            } finally {
                              setState(() {
                                _isLoadingSave = false;
                              });
                            }
                          },
                    child: _isLoadingSave
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.red),
                            ),
                          )
                        : Icon(
                            Icons.message,
                            size: 20,
                            color: widget.isSaved ? Colors.red : Colors.grey,
                          ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _isLoadingFavorite
                        ? null
                        : () async {
                            setState(() {
                              _isLoadingFavorite = true;
                            });
                            try {
                              if (widget.onTaplike != null) {
                                await widget.onTaplike!();
                                setState(() {
                                  widget.isFavorite = !widget.isFavorite;
                                });
                              }
                            } finally {
                              setState(() {
                                _isLoadingFavorite = false;
                              });
                            }
                          },
                    child: _isLoadingFavorite
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.red),
                            ),
                          )
                        : Icon(
                            Icons.favorite,
                            size: 20,
                            color: widget.isFavorite ? Colors.red : Colors.grey,
                          ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: widget.onTapadd,
                    child: Icon(Icons.add_box_outlined,
                        size: 20, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
