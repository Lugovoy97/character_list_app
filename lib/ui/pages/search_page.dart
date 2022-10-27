import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rickandmorty/bloc/character_bloc.dart';
import 'package:rickandmorty/data/models/character.dart';
import 'package:rickandmorty/ui/widgets/custom_list_tile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late Character _currentCharacter;
  List<Results> _currentResults = [];
  int _currentPage = 1;
  String _currentSearchStr = '';

  final refreshController = RefreshController();
  bool _isPagination = false;
  
  @override
  void initState() {
    if(_currentResults.isEmpty){
      context
        .read<CharacterBloc>()
        .add(const CharacterEvent.fetch(name: '', page: 1));
    }
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    final state = context.watch<CharacterBloc>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // const Padding(
        //   padding: EdgeInsets.all(4.0),
        //   child: TextField(
        //     decoration: InputDecoration(
        //       filled: true,
        //       hintText: 'Search Name'
        //     ),
        //     onChanged: (value) {
        //       _currentPage = 1;
        //       _currentResults = [];
        //       _currentSearchStr = value;
        //       context
        //         .read<CharacterBloc>()
        //         .add(CharacterEvent.fetch(name: value, page: _currentPage));
        //     },
        //   ),
        // ),
        SizedBox(height: 12),
        Expanded(
          child: state.when(
            loading: () {
              if(!_isPagination){
                return Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(strokeWidth: 2),
                      SizedBox(width: 10),
                      Text('Loading...')
                    ],
                  ),
                );
              } else {
                return _customListView(_currentResults);
              }
            },
            loaded: (characterLoaded) {
              _currentCharacter = characterLoaded;
              if(_isPagination) {
                _currentResults = List.from(_currentResults)..addAll(_currentCharacter.results);
                refreshController.loadComplete();
                _isPagination = false;
              } else {
                _currentResults = _currentCharacter.results;
              }
              return _currentResults.isNotEmpty
                ? _customListView(_currentResults)
                : SizedBox();
            },
            error: () => const Text('Nothing found...')
          ),
        ),
      ],
    );
  }

  Widget _customListView(List<Results> currentResults){
    return SmartRefresher(
      controller: refreshController,
      enablePullUp: true,
      enablePullDown: false,
      onLoading: () {
        _isPagination = true;
        _currentPage++;
        if(_currentPage <= _currentCharacter.info.pages) {
          context.read<CharacterBloc>()
            .add(CharacterEvent.fetch(
              name: _currentSearchStr,
              page: _currentPage
            )
          );
        } else {
          refreshController.loadNoData();
        }
      },
      child: ListView.separated(
        itemCount: currentResults.length,
        separatorBuilder: (_, index) => const SizedBox(height: 5),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final result = currentResults[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16, left: 16, top: 3, bottom: 3),
            child: CustomListTile(
              result: result,
            ),
          );
        }
      ),
    );
  }
}
