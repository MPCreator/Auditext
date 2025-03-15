import 'package:flutter/material.dart';
import '../utils/routes/route_names.dart';
import '../utils/themes/button_styles.dart';
import '../utils/themes/sizes.dart';

class HomeScreen extends StatelessWidget {

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.customSizeWidth(context, 0.1),),
          child: Center(
            child: Column(
              children: [
                SizedBox(height: AppSizes.customSizeHeight(context, 0.03)),
                Text(
                  'AuditTex',
                  style: TextStyle(
                    fontSize: AppSizes.customSizeWidth(context, 0.1),
                    fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: AppSizes.customSizeHeight(context, 0.25)),
                SizedBox(
                  width: AppSizes.customSizeWidth(context, 0.6),
                  height: AppSizes.customSizeHeight(context, 0.05),
                  child: ElevatedButton(
                    style: ButtonStyles.primaryButtonStyle,
                    onPressed: () {Navigator.of(context).pushNamed(RouteNames.loadOrder);},
                    child: Text('Nueva Auditoría',
                        style: TextStyle(fontSize: AppSizes.customSizeHeight(context, 0.019))
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.mediumSpace(context)),
                SizedBox(
                  width: AppSizes.customSizeWidth(context, 0.6),
                  height: AppSizes.customSizeHeight(context, 0.05),
                  child: ElevatedButton(
                    style: ButtonStyles.primaryButtonStyle,
                    onPressed: () {Navigator.of(context).pushNamed(RouteNames.auditList);},
                    child: Text('Auditorías existentes',
                      style: TextStyle(fontSize: AppSizes.customSizeHeight(context, 0.019)),
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.mediumSpace(context)),
                SizedBox(
                  width: AppSizes.customSizeWidth(context, 0.6),
                  height: AppSizes.customSizeHeight(context, 0.05),
                  child: ElevatedButton(
                    style: ButtonStyles.primaryButtonStyle,
                    onPressed: () {
                      Navigator.of(context).pushNamed(RouteNames.settings);
                    },
                    child: Text('Configurar Auditorías',
                        style: TextStyle(fontSize: AppSizes.customSizeHeight(context, 0.019))
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}