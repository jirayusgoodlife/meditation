class SettingData {
  SettingData(this.name, this.value);
  String name;
  var value;

  @override
  String toString() {
    return "${this.name} => ${this.value}";
  }
}