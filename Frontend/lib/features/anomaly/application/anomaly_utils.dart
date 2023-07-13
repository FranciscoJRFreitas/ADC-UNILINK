import 'package:flutter/material.dart';

Color getStatusColor(String status) {
  switch (status) {
    case 'Detected':
      return Colors.yellow;
    case 'Confirmed':
      return Colors.orange;
    case 'Rejected':
      return Colors.red;
    case 'In Progress':
      return Colors.blue;
    case 'Solved':
      return Colors.green;
    default:
      return Colors.grey;
  }
}

