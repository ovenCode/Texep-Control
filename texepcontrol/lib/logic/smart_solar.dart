import 'package:texepcontrol/logic/isolar_device.dart';

/// Class that represents an instance of a SmartSolar device
///
/// *** WORK IN PROGRESS ***
/// Contains all the characteristics/members that can be controlled remotely
class SmartSolar implements ISolarDevice {
  SmartSolar();

  /// Constructor of the model 250/70
  ///
  /// Id for VE.Direct is 0xA05B based on the data from https://www.victronenergy.com/upload/documents/BlueSolar-HEX-protocol.pdf (page 4)
  /// or https://www.victronenergy.com/upload/documents/VE.Direct-Protocol-3.32.pdf (page 11)
  ///
  SmartSolar.model25070();
}
