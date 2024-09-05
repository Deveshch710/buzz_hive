import 'package:flutter/material.dart';

import '../Constants.dart';

class SearchWidget extends StatefulWidget {
  final Function(String) onSearch;

  const SearchWidget({Key? key, required this.onSearch}) : super(key: key);

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
            ),
            width: MediaQuery.of(context).size.width * .9,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search,
                  color: Colors.black54.withOpacity(.6),
                ),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    showCursor: false,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    onChanged: (value) => widget.onSearch(value),
                  ),
                ),
                Icon(
                  Icons.mic,
                  color: Colors.black54.withOpacity(.6),
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: Constants.primarycolor.withOpacity(.3),
              borderRadius: BorderRadius.circular(20),
            ),
          )
        ],
      ),
    );
  }
}