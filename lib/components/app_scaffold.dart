import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../utils/colors.dart';
import '../utils/common_base.dart';
import 'body_widget.dart';
import 'loader_widget.dart';

class AppScaffold extends StatelessWidget {
  final bool hideAppBar;
  //
  final Widget? leadingWidget;
  final Widget? appBarTitle;
  final List<Widget>? actions;
  final bool isCenterTitle;
  final bool automaticallyImplyLeading;
  final double? appBarelevation;
  final String? appBartitleText;
  final Color? appBarbackgroundColor;
  //
  final Widget body;
  final Color? scaffoldBackgroundColor;
  final RxBool? isLoading;
  //
  final Widget? bottomNavBar;
  final Widget? fabWidget;
  final bool hasLeadingWidget;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool? resizeToAvoidBottomPadding;

  const AppScaffold({
    super.key,
    this.hideAppBar = false,
    //
    this.leadingWidget,
    this.appBarTitle,
    this.actions,
    this.appBarelevation = 0,
    this.appBartitleText,
    this.appBarbackgroundColor,
    this.isCenterTitle = false,
    this.hasLeadingWidget = true,
    this.automaticallyImplyLeading = false,
    //
    required this.body,
    this.isLoading,
    //
    this.bottomNavBar,
    this.fabWidget,
    this.floatingActionButtonLocation,
    this.resizeToAvoidBottomPadding,
    this.scaffoldBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomPadding,
      appBar: hideAppBar
          ? null
          : PreferredSize(
              preferredSize: Size(Get.width, 66),
              child: AppBar(
                elevation: appBarelevation,
                automaticallyImplyLeading: automaticallyImplyLeading,
                backgroundColor:
                    appBarbackgroundColor ?? context.scaffoldBackgroundColor,
                centerTitle: isCenterTitle,
                titleSpacing: 2,
                title: appBarTitle ??
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: hasLeadingWidget ? 0 : 16,
                      ),
                      child: Text(
                        appBartitleText ?? "",
                        style: primaryTextStyle(size: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                actions: actions,
                leading:
                    leadingWidget ?? (hasLeadingWidget ? backButton() : null),
              ).paddingTop(10),
            ),
      backgroundColor:
          scaffoldBackgroundColor ?? context.scaffoldBackgroundColor,
      body: Body(
        isLoading: isLoading,
        child: body,
      ),
      bottomNavigationBar: bottomNavBar,
      floatingActionButton: fabWidget,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}

class AppScaffoldNew extends StatelessWidget {
  final Widget body;
  final Widget? appBarChild;
  final Widget? leadingWidget;
  final String? appBartitleText;
  final bool hasLeadingWidget;
  final List<Widget>? actions;
  final double? appBarVerticalSize;
  final Color? topBarBgColor;
  final bool? resizeToAvoidBottomPadding;
  final Color? scaffoldBackgroundColor;
  final RxBool? isLoading;
  final List<Widget> widgetsStackedOverBody;
  final bool hideAppBar;
  final bool isBlurBackgroundinLoader;
  final Clip clipBehaviorSplitRegion;
  final Widget? fabWidget;

  const AppScaffoldNew({
    super.key,
    required this.body,
    this.appBarChild,
    this.leadingWidget,
    this.appBartitleText,
    this.hasLeadingWidget = true,
    this.actions,
    this.appBarVerticalSize,
    this.topBarBgColor,
    this.resizeToAvoidBottomPadding,
    this.scaffoldBackgroundColor,
    this.isLoading,
    this.widgetsStackedOverBody = const [],
    this.hideAppBar = false,
    this.isBlurBackgroundinLoader = false,
    this.clipBehaviorSplitRegion = Clip.antiAlias,
    this.fabWidget,
  });

  double get topBarHeight =>
      hideAppBar ? 0 : appBarVerticalSize ?? Get.height * 0.15;

  /// The status bar is transparent, so its icons must contrast with the
  /// top-bar colour instead of the app's overall light/dark theme.
  SystemUiOverlayStyle get systemUiOverlayStyle {
    final hasDarkTopBar =
        (topBarBgColor ?? appColorPrimary).computeLuminance() < 0.5;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          hasDarkTopBar ? Brightness.light : Brightness.dark,
      statusBarBrightness: hasDarkTopBar ? Brightness.dark : Brightness.light,
    );
  }

  Widget get topBarComponent =>
      appBarChild ??
      SizedBox(
        width: Get.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      appBartitleText ?? "",
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: primaryTextStyle(
                          size: 18, fontFamily: 'Outfit', color: white),
                    ).expand(),
                  ],
                ).paddingSymmetric(horizontal: Get.width * 0.12),
                PositionedDirectional(
                  start: 0,
                  child: leadingWidget ??
                      (hasLeadingWidget
                          ? BackButton(
                              onPressed: () {
                                Get.back();
                              },
                              color: white,
                            )
                          : const Offstage()),
                ),
                PositionedDirectional(
                  end: 0,
                  child: Row(
                    children: actions ?? [],
                  ),
                )
              ],
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiOverlayStyle,
      child: Scaffold(
        resizeToAvoidBottomInset: resizeToAvoidBottomPadding,
        backgroundColor:
            scaffoldBackgroundColor ?? context.scaffoldBackgroundColor,
        body: SafeArea(
          top: false,
          child: Stack(
            children: [
              Container(
                width: Get.width,
                height: Get.height,
                decoration:
                    BoxDecoration(color: topBarBgColor ?? appColorPrimary),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned(
                      height: topBarHeight,
                      child: Container(
                        child:
                            topBarComponent.paddingTop(context.statusBarHeight),
                      ),
                    ),
                    Container(
                      clipBehavior: clipBehaviorSplitRegion,
                      margin: EdgeInsets.only(top: topBarHeight),
                      decoration: boxDecorationDefault(
                        color: scaffoldBackgroundColor ??
                            context.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(defaultRadius * 2),
                          topRight: Radius.circular(defaultRadius * 2),
                        ),
                      ),
                      child: body,
                    ),
                    ...widgetsStackedOverBody,
                  ],
                ),
              ),
              if (isLoading != null)
                Obx(
                  () => isLoading!.value
                      ? BlockingLoaderWidget(
                          isBlurBackground: isBlurBackgroundinLoader,
                        )
                      : const SizedBox.shrink(),
                ),
            ],
          ),
        ),
        floatingActionButton: fabWidget,
      ),
    );
  }
}
