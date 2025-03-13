import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/routes.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Provider/productDetailProvider.dart';
import 'package:eshop_multivendor/Screen/Language/languageSettings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CompareProduct extends StatelessWidget {
  Product? model;
  CompareProduct({Key? key, this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      
      elevation: 0,
      child: InkWell(
        onTap: () {
          if (context.read<ProductDetailProvider>().compareList.length > 0 &&
              context
                  .read<ProductDetailProvider>()
                  .compareList
                  .contains(model)) {
            Routes.navigateToCompareListScreen(context);
          } else {
            context.read<ProductDetailProvider>().addCompareList(model!);
            Routes.navigateToCompareListScreen(context);
          }
        },
        child: ListTile(
                //contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(
                  getTranslated(context, 'COMPARE_PRO'),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.fontColor,
                  ),
                ),
                trailing:  Icon(Icons.keyboard_arrow_right, color: Theme.of(context).colorScheme.primary,),
              ),
          
      ),
    );
  }
}
