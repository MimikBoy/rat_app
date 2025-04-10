import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class TrainerHomePage extends StatelessWidget {
  const TrainerHomePage({super.key});
 
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: 3,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  index.toString(),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      
                    },
                    icon: Icon(Icons.download_rounded),
                    color: Colors.green,
                  ),
                  IconButton(
                    onPressed: () {
                    },
                    icon: Icon(Icons.delete_rounded),
                    color: Colors.red,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}