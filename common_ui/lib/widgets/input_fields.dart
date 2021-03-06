import 'package:common_ui/common_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget inputField({
  Key inputFieldKey,
  Key errorFieldKey,
  @required TextEditingController controller,
  @required String hint,
  TextInputType keyboardType = TextInputType.text,
  textInputAction: TextInputAction.done,
  bool obscureText = false,
  bool showClearButton = false,
  String error,
  String prefixIconAsset,
}) {
  return Container(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextFormField(
          key: inputFieldKey ?? UniqueKey(),
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          textInputAction: textInputAction,
          decoration: InputDecoration(
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
              color:
                  error != null ? SdColors.errorColor : SdColors.secondaryColor,
            )),
            hintText: hint,
            hintStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: SdColors.greyColor,
            ),
            prefixIcon: _getPrefixIcon(prefixIconAsset),
            prefixIconConstraints: BoxConstraints.expand(
              width: Dimens.unit3,
              height: Dimens.unit3,
            ),
            prefix: SizedBox(
              width: Dimens.unit,
            ),
            suffixIcon: Visibility(
              visible: showClearButton,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: IconButton(
                icon: Icon(Icons.clear, size: Dimens.unit2),
                onPressed: () => controller.clear(),
              ),
            ),
          ),
        ),
        if (errorFieldKey != null) SizedBox(height: Dimens.unit),
        if (errorFieldKey != null)
          Visibility(
            child: Text(
              error ?? SdStrings.empty,
              key: errorFieldKey ?? UniqueKey(),
              style: TextStyle(
                color: SdColors.errorColor,
                fontSize: Dimens.fontSize12,
              ),
            ),
            visible: error != null,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
          ),
      ],
    ),
  );
}

Widget _getPrefixIcon(String prefixIconAsset) {
  if (prefixIconAsset == null) {
    return null;
  }

  return Container(
    child: SvgPicture.asset(
      prefixIconAsset,
      package: commonUiPackage,
    ),
  );
}

Widget searchField({
  @required String key,
  @required TextEditingController controller,
  String hint,
  Function(String) onFieldSubmitted,
}) {
  return TextFormField(
    key: Key(key),
    controller: controller,
    textInputAction: TextInputAction.search,
    onFieldSubmitted: onFieldSubmitted,
    decoration: InputDecoration(hintText: hint),
    style: TextStyle(),
  );
}
