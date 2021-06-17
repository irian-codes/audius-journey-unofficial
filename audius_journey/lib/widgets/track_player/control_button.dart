// Copyright 2018 Pawan Kumar

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

//    http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Original source code at https://github.com/iampawan/Flutter-Music-Player

// Modifications copyright (C) 2021 Irian Montón Beltrán
//
// Changed name of the original file from 'mp_control_button.dart' to the
// current one.

import 'package:flutter/material.dart';

class ControlButton extends StatelessWidget {
  final VoidCallback _onTap;
  final IconData iconData;

  ControlButton(this.iconData, this._onTap);

  @override
  Widget build(BuildContext context) {
    return new IconButton(
      onPressed: _onTap,
      iconSize: 50.0,
      icon: new Icon(iconData),
      color: Theme.of(context).buttonColor,
    );
  }
}
