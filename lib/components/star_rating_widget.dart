import 'package:flutter/material.dart';

class StarRating extends StatefulWidget {
  final int starCount;
  final double rating;
  final ValueChanged<double> onRatingChanged;
  final Color color;

  StarRating(
      {this.starCount = 5,
      this.rating = 0.0,
      required this.onRatingChanged,
      required this.color});

  @override
  _StarRatingState createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  @override
  Widget build(BuildContext context) {
    double size = 40.0; // ขนาดของดาว
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.starCount, (index) {
        return GestureDetector(
          onTap: () {
            widget.onRatingChanged(index + 1.0);
          },
          child: Icon(
            index < widget.rating ? Icons.star : Icons.star_border,
            color: widget.color,
            size: size,
          ),
        );
      }),
    );
  }
}
