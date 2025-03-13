import 'dart:async';
import 'dart:io';
import 'package:eshop_multivendor/Helper/ApiBaseHelper.dart';
import 'package:eshop_multivendor/Provider/addressProvider.dart';
import 'package:eshop_multivendor/Provider/homePageProvider.dart';
import 'package:eshop_multivendor/Screen/Chat/Chat.dart';
import 'package:eshop_multivendor/Screen/Product_Detail/Widget/chateWithSeller.dart';
import 'package:eshop_multivendor/Screen/Product_Detail/Widget/compareProduct.dart';
import 'package:eshop_multivendor/Screen/Product_Detail/Widget/deliveryPinCode.dart';
import 'package:eshop_multivendor/Screen/Product_Detail/Widget/productExtraDetail.dart';
import 'package:eshop_multivendor/Screen/Product_Detail/Widget/statesticsAnimatedHighlightWidget.dart';
import 'package:eshop_multivendor/cubits/appSettingsCubit.dart';
import 'package:eshop_multivendor/main.dart';
import 'package:eshop_multivendor/Helper/Color.dart';
import 'package:eshop_multivendor/Helper/Constant.dart';
import 'package:eshop_multivendor/Model/Section_Model.dart';
import 'package:eshop_multivendor/Model/User.dart';
import 'package:eshop_multivendor/Provider/CartProvider.dart';
import 'package:eshop_multivendor/Provider/UserProvider.dart';
import 'package:eshop_multivendor/widgets/customSelectionContainer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../Helper/String.dart';
import '../../Helper/routes.dart';
import '../../Model/Faqs_Model.dart';
import '../../Provider/SettingProvider.dart';
import '../../Provider/productDetailProvider.dart';
import '../../Provider/Favourite/FavoriteProvider.dart';
import '../../Provider/promoCodeProvider.dart';
import '../../widgets/desing.dart';
import '../Language/languageSettings.dart';
import '../../widgets/networkAvailablity.dart';
import '../../widgets/snackbar.dart';
import '../../widgets/validation.dart';
import '../ProductPreview/productPreview.dart';
import '../Dashboard/Dashboard.dart';
import '../NoInterNetWidget/NoInterNet.dart';
import 'Widget/ProductHighLight.dart';
import 'Widget/allQuestionButton.dart';
import 'Widget/commanFiledsofProduct.dart';
import 'Widget/productItemList.dart';
import 'Widget/postFaq.dart';
import 'Widget/productMoreDetail.dart';
import 'Widget/reviewUI.dart';
import 'Widget/sellerDetail.dart';
import 'Widget/specialExtraOfferBtn.dart';

class ProductDetail extends StatefulWidget {
  Product? model;
  final bool fromCart;
  final int? secPos, index;
  final bool? list;
  final int? selectedVarientIndex;

  ProductDetail(
      {super.key,
      this.model,
      this.index,
      this.secPos,
      this.list,
      this.fromCart = false,
      this.selectedVarientIndex});

  @override
  State<StatefulWidget> createState() => StateItem();
}

TextEditingController qtyController = TextEditingController();

class StateItem extends State<ProductDetail> with TickerProviderStateMixin {
  FocusNode searchFocusNode = FocusNode();
  late final AnimationController buttonAnimationController =
      AnimationController(
          vsync: this, duration: const Duration(milliseconds: 300));

  late final Animation<double> heightAnimation = Tween<double>(
    begin: Platform.isIOS ? 70 : 50, // Initial height
    end: 0, // Final height
  ).animate(
    CurvedAnimation(
      parent: buttonAnimationController,
      curve: const Interval(0.0, 1.0, curve: Curves.linear),
    ),
  );

  int _curSlider = 0;
  final _pageController = PageController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ChoiceChip? choiceChip, tagChip;
  Widget? choiceContainer;

  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool loading = true;

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  int notificationoffset = 0;
  late int totalProduct = 0;

  bool notificationisloadmore = true,
      notificationisgettingdata = false,
      notificationisnodata = false;

  bool notificationisgettingdata1 = false, notificationisnodata1 = false;
  List<Product> productList = [];
  List<Product> productList1 = [];

  late String shareLink;
  late String curPin;
  TextEditingController curcity = TextEditingController();
  late double growStepWidth, beginWidth, endWidth = 0.0;
  ScrollController controller = ScrollController();
  List<String?> sliderList = [];

  List<Product> compareList = [];
  bool isBottom = false;

  List<String> proIds1 = [];
  List<Product> mostFavProList = [];
  String query = '';

  bool isLoadedAll = true;

  String deliveryDate = '',
      codDeliveryCharges = '',
      prePaymentDeliveryCharges = '',
      deliveryMsg = '';

  final ScrollController _cityScrollController = ScrollController();

  late int selectedProductVariantIndex = widget.selectedVarientIndex ?? 0;

  final List<AttributeSelection> attributes = [];

  @override
  void initState() {
    super.initState();
    callApi();
    context.read<ProductDetailProvider>().seeView = false;
    context.read<ProductDetailProvider>().isLoadingmore = true;
    allApiAndFun();
    checkProId();
    promocodeAPI('0');

    context.read<ProductDetailProvider>().faqsProductList.clear();
    context.read<ProductDetailProvider>().faqsOffset = 0;

    controller = ScrollController(keepScrollOffset: true);
    controller.addListener(_scrollListener);
    _cityScrollController.addListener(_scrollListenercity);
    getProduct1();
    getProFavIds();
    sliderList.clear();
    sliderList.insert(0, widget.model!.image);

    addImage().then((value) {
      if (widget.model!.videType != '' &&
          widget.model!.video!.isNotEmpty &&
          widget.model!.video != '') {
        sliderList.insert(1, 'youtube');
      }
    });

    context.read<ProductDetailProvider>().reviewImgList.clear();
    if (widget.model!.reviewList!.isNotEmpty) {
      for (int i = 0;
          i < widget.model!.reviewList![0].productRating!.length;
          i++) {
        for (int j = 0;
            j < widget.model!.reviewList![0].productRating![i].imgList!.length;
            j++) {
          imgModel m = imgModel.fromJson(
            i,
            widget.model!.reviewList![0].productRating![i].imgList![j],
          );
          context.read<ProductDetailProvider>().reviewImgList.add(m);
        }
      }
    }

    context.read<ProductDetailProvider>().reviewList.clear();
    context.read<ProductDetailProvider>().offset = 0;
    context.read<ProductDetailProvider>().total = 0;
    getReview();
    getDeliverable();
    notificationoffset = 0;
    getProduct();

    getProductDetails();

    compareList = context.read<ProductDetailProvider>().compareList;

    buttonController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(
      CurvedAnimation(
        parent: buttonController!,
        curve: const Interval(
          0.0,
          0.150,
        ),
      ),
    );
  }

  Future<void> getProductDetails() async {
    if (isNetworkAvail) {
      try {
        var parameter = {
          'product_ids': widget.model!.id,
          IS_DETAILED_DATA: '1',
        };

        ApiBaseHelper().postAPICall(getProductApi, parameter).then(
            (getdata) async {
          bool error = getdata['error'];
          if (!error) {
            var data = getdata['data'];

            List<Product> tempList =
                (data as List).map((data) => Product.fromJson(data)).toList();

            setState(() {
              widget.model = tempList[0];
              loading = false;
            });
            selectedProductVariantIndex = widget.selectedVarientIndex ?? 0;
            for (int i = 0;
                i < (widget.model!.attributeList?.length ?? 0);
                i++) {
              List<String> variantAttributes = widget
                  .model!
                  .prVarientList![selectedProductVariantIndex]
                  .attribute_value_ids!
                  .split(',');
              int index = 0;
              for (int j = 0; j < variantAttributes.length; j++) {
                index = widget.model!.attributeList![i].getIdList().indexWhere(
                    (element) => element.trim() == variantAttributes[j]);

                if (index == -1) {
                  index = 0;
                } else {
                  break;
                }
              }
              attributes.add(AttributeSelection(
                oneAttributeList: widget.model!.attributeList![i],
                selectedId: widget.model!.attributeList![i].getId(index),
              ));
            }

            setState(() {
              isLoadedAll = true;
            });
          }
        }, onError: (error) {
          setSnackbar(error.toString(), context);
        });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg'), context);
      }
    } else {
      if (mounted) {
        setState(() {
          isNetworkAvail = false;
          context.read<HomePageProvider>().mostLikeLoading = false;
        });
      }
    }
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (mounted) {
        if (mounted) {
          setState(
            () {
              context.read<ProductDetailProvider>().isLoadingmore = true;

              getProductFaqs();
            },
          );
        }
      }
    }
  }

  _scrollListenercity() async {
    if (_cityScrollController.offset >=
            _cityScrollController.position.maxScrollExtent &&
        !_cityScrollController.position.outOfRange) {
      if (mounted) {
        setState(
          () {
            context.read<AddressProvider>().isLoadingMoreCity = true;
            context.read<AddressProvider>().isProgress = true;
          },
        );

        await context
            .read<AddressProvider>()
            .getCities(false, context, setState, false, widget.index);
      }
    }
  }

  Future<void> promocodeAPI(String save) async {
    Future.delayed(Duration.zero).then((value) =>
        context.read<PromoCodeProvider>().getPromoCodes(isLoadingMore: false));
  }

  getProFavIds() async {
    proIds1 = (await db.getMostFav())!;
    getMostFavPro();
  }

  checkProId() async {
    await db.addMostFav(widget.model!.id!);
  }

  Future<void> getMostFavPro() async {
    if (proIds1.isNotEmpty) {
      isNetworkAvail = await isNetworkAvailable();

      if (isNetworkAvail) {
        try {
          var parameter = {'product_ids': proIds1.join(',')};

          ApiBaseHelper().postAPICall(getProductApi, parameter).then(
              (getdata) async {
            bool error = getdata['error'];
            if (!error) {
              var data = getdata['data'];

              List<Product> tempList =
                  (data as List).map((data) => Product.fromJson(data)).toList();
              mostFavProList.clear();
              bool currentProductCheckingFlag = false;
              for (var element in tempList) {
                if (element.id == widget.model!.id) {
                  currentProductCheckingFlag = true;
                }
              }
              if (!currentProductCheckingFlag) {
                mostFavProList.addAll(tempList);
              } else {
                tempList
                    .removeWhere((element) => element.id == widget.model!.id);
                mostFavProList.addAll(tempList);
              }
            }
            if (mounted) {
              setState(
                () {
                  context.read<HomePageProvider>().mostLikeLoading = false;
                },
              );
            }
          }, onError: (error) {
            setSnackbar(error.toString(), context);
          });
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg'), context);
          context.read<HomePageProvider>().mostLikeLoading = false;
        }
      } else {
        if (mounted) {
          setState(() {
            isNetworkAvail = false;
            context.read<HomePageProvider>().mostLikeLoading = false;
          });
        }
      }
    } else {
      context.read<CartProvider>().setCartlist([]);
      setState(
        () {
          context.read<HomePageProvider>().mostLikeLoading = false;
        },
      );
    }
  }

  Future<void> getProductFaqs() async {
    try {
      isNetworkAvail = await isNetworkAvailable();
      if (isNetworkAvail) {
        try {
          if (context.read<ProductDetailProvider>().isLoadingmore) {
            if (mounted) {
              setState(
                () {
                  context.read<ProductDetailProvider>().isLoadingmore = false;

                },
              );
            }
            var parameter = {
              PRODUCT_ID: widget.model!.id,
              LIMIT: perPage.toString(),
              OFFSET:
                  context.read<ProductDetailProvider>().faqsOffset.toString(),
              SEARCH: query,
            };
            ApiBaseHelper().postAPICall(getProductFaqsApi, parameter).then(
              (getdata) {
                bool error = getdata['error'];
                if (!error) {
                  var data = getdata['data'];
                  context.read<ProductDetailProvider>().faqsProductList =
                      (data as List)
                          .map((data) => FaqsModel.fromJson(data))
                          .toList();
                  context.read<ProductDetailProvider>().isLoadingmore = true;
                  context.read<ProductDetailProvider>().isFaqsLoading = false;
                  context.read<ProductDetailProvider>().faqsOffset =
                      context.read<ProductDetailProvider>().faqsOffset +
                          perPage;
                  setState(() {});
                } else {
                  context.read<ProductDetailProvider>().isLoadingmore = false;
                  context.read<ProductDetailProvider>().isFaqsLoading = false;
                  setState(() {});
                }
                if (mounted) {
                  setState(
                    () {
                      context.read<ProductDetailProvider>().isFaqsLoading =
                          false;
                    },
                  );
                  context.read<ProductDetailProvider>().isLoadingmore = false;
                  if (mounted) {
                    setState(
                      () {},
                    );
                  }
                }
              },
              onError: (error) {
                setSnackbar(error.toString(), context);
              },
            );
          }
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg'), context);
          if (mounted) {
            setState(
              () {
                context.read<ProductDetailProvider>().isLoadingmore = false;
                context.read<ProductDetailProvider>().isFaqsLoading = false;
              },
            );
          }
        }
      } else {
        if (mounted) {
          setState(
            () {
              isNetworkAvail = false;
            },
          );
        }
      }
    } on FormatException catch (e) {
      setSnackbar(e.message, context);
    }
  }

  Future<void> addImage() async {
    if (widget.model!.otherImage!.isNotEmpty) {
      sliderList.addAll(widget.model!.otherImage!);
    }

    for (int i = 0; i < widget.model!.prVarientList!.length; i++) {
      for (int j = 0; j < widget.model!.prVarientList![i].images!.length; j++) {
        sliderList.add(widget.model!.prVarientList![i].images![j]);
      }
    }
  }

  Future<String> generateShortDynamicLink() async {
    return "https://$shareNavigationWebUrl/products/details/${widget.model!.slug}";
  }

  Future<String> generateShortDynamicLinkOfProduct() async {
    return await generateShortDynamicLink();
  }

  Future<void> createDynamicLink() async {
    String shortenedLink = await generateShortDynamicLinkOfProduct();

    Share.share(shortenedLink,
        sharePositionOrigin: Rect.fromLTWH(
            0,
            0,
            MediaQuery.of(context).size.width,
            MediaQuery.of(context).size.height / 2));
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  setStateNoInternate() async {
    _playAnimation();

    Future.delayed(const Duration(seconds: 2)).then(
      (_) async {
        isNetworkAvail = await isNetworkAvailable();
        if (isNetworkAvail) {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (BuildContext context) => super.widget,
            ),
          );
        } else {
          await buttonController!.reverse();
          if (mounted) {
            setState(
              () {},
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      top: false,
      bottom: false,
      // bottom: Platform.isAndroid ? false : true,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: isBottom
            ? Colors.transparent.withOpacity(0.5)
            : Theme.of(context).canvasColor,
        body: isNetworkAvail
            ? Stack(
                children: <Widget>[
                  _showContent(),
                  Selector<CartProvider, bool>(
                    builder: (context, data, child) {
                      return DesignConfiguration.showCircularProgress(
                        data,
                        colors.primary,
                      );
                    },
                    selector: (_, provider) => provider.isProgress,
                  ),
                ],
              )
            : NoInterNet(
                setStateNoInternate: setStateNoInternate,
                buttonSqueezeanimation: buttonSqueezeanimation,
                buttonController: buttonController,
              ),
      ),
    );
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(
        handler(i, list[i]),
      );
    }

    return result;
  }

  Widget _slider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => ProductPreview(
                  pos: _curSlider,
                  index: widget.index,
                  id: widget.model!.id,
                  imgList: sliderList,
                  list: widget.list,
                  video: widget.model!.video,
                  videoType: widget.model!.videType,
                  from: true,
                ),
              ),
            );
          },
          child: Stack(
            children: <Widget>[
              Hero(
                tag: '$heroTagUniqueString${widget.index}${widget.model!.id}',
                child: PageView.builder(
                  itemCount: sliderList.length,
                  scrollDirection: Axis.horizontal,
                  controller: _pageController,
                  reverse: false,
                  onPageChanged: (index) {
                    setState(
                      () {
                        _curSlider = index;
                      },
                    );
                  },
                  itemBuilder: (BuildContext context, int index) {
                    return Stack(
                      children: [
                        sliderList[index] != 'youtube'
                            ? DesignConfiguration.getCacheNotworkImage(
                                boxFit:
                                    extendImg ? BoxFit.cover : BoxFit.contain,
                                context: context,
                                heightvalue: constraints.maxHeight,
                                widthvalue: constraints.maxWidth,
                                placeHolderSize: deviceWidth! * 1,
                                imageurlString: sliderList[index]!,
                              )
                            : playIcon()
                      ],
                    );
                  },
                ),
              ),
              Positioned.directional(
                textDirection: Directionality.of(context),
                bottom: 30,
                height: 20,
                width: deviceWidth,
                child: Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: map<Widget>(
                        sliderList,
                        (index, url) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            width: 8.0,
                            height: 8.0,
                            margin: const EdgeInsets.symmetric(
                              vertical: 2.0,
                              horizontal: 4.0,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(circularBorderRadius4)),
                              color: _curSlider == index
                                  ? colors.primary
                                  : Theme.of(context).colorScheme.lightWhite,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              indicatorImage(),
            ],
          ),
        );
      },
    );
  }

  indicatorImage() {
    String? indicator = widget.model!.indicator;
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: indicator == '1'
              ? SvgPicture.asset(
                  DesignConfiguration.setSvgPath('vag'),
                )
              : indicator == '2'
                  ? SvgPicture.asset(
                      DesignConfiguration.setSvgPath('nonvag'),
                    )
                  : const SizedBox(),
        ),
      ),
    );
  }

  getCityList(StateSetter setStater, AddressProvider data) {
    return data.citySearchLIst
        .asMap()
        .map(
          (index, element) => MapEntry(
            index,
            InkWell(
              onTap: () {
                if (mounted) {
                  setStater(
                    () {
                      data.selCityPos = index;
                      Navigator.of(context).pop();
                    },
                  );
                  curcity.text = data.citySearchLIst[data.selCityPos!].name!;
                  setState(() {});
                }
              },
              child: SizedBox(
                width: double.maxFinite,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    data.citySearchLIst[index].name!,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontFamily: 'ubuntu',
                        ),
                  ),
                ),
              ),
            ),
          ),
        )
        .values
        .toList();
  }

  cityDialog() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setStater) {
              context.read<AddressProvider>().setCitySetter(setStater);

              return AlertDialog(
                contentPadding: const EdgeInsets.all(0.0),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(circularBorderRadius5),
                  ),
                ),
                content:
                    Consumer<AddressProvider>(builder: (context, data, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 0, 0),
                        child: Text(
                          getTranslated(context, 'CITYSELECT_LBL'),
                          style: Theme.of(this.context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                                  fontFamily: 'ubuntu',
                                  color:
                                      Theme.of(context).colorScheme.fontColor),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: TextField(
                                controller: data.cityController,
                                // autofocus: false,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.fontColor,
                                ),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.fromLTRB(
                                      0, 15.0, 0, 15.0),
                                  hintText:
                                      getTranslated(context, 'SEARCH_LBL'),
                                  hintStyle: TextStyle(
                                      color: colors.primary.withOpacity(0.5)),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: IconButton(
                              onPressed: () async {
                                data.isLoadingMoreCity = true;
                                await data.getCities(
                                  true,
                                  context,
                                  setStater,
                                  false,
                                  widget.index,
                                );
                                setState(() {});
                              },
                              icon: const Icon(
                                Icons.search,
                                size: 20,
                              ),
                            ),
                          )
                        ],
                      ),
                      data.cityLoading
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 50.0),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : Flexible(
                              child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                                child: SingleChildScrollView(
                                  controller: _cityScrollController,
                                  child: Stack(
                                    children: [
                                      Column(
                                        children: [
                                          if (IS_SHIPROCKET_ON == '1')
                                            InkWell(
                                              onTap: () {
                                                setStater(() {
                                                  data.isZipcode = false;

                                                  data.selZipcode = null;
                                                  data.zipcodeC!.text = '';
                                                  data.cityEnable = true;
                                                  data.zipcodeEnable = true;
                                                  data.selCityPos = -1;
                                                  Navigator.of(context).pop();
                                                });
                                                setState(() {});
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Text(
                                                    getTranslated(context,
                                                        'OTHER_CITY_LBL'),
                                                    textAlign: TextAlign.start,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleSmall!
                                                        .copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .primary),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          (data.citySearchLIst.isNotEmpty)
                                              ? Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: getCityList(
                                                      setStater, data),
                                                )
                                              : Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 20.0),
                                                  child: DesignConfiguration
                                                      .getNoItem(context),
                                                ),
                                          Center(
                                            child: DesignConfiguration
                                                .showCircularProgress(
                                              data.isLoadingMoreCity!,
                                              colors.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      DesignConfiguration.showCircularProgress(
                                        data.isProgress,
                                        colors.primary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                    ],
                  );
                }),
              );
            },
          );
        },
      );
    });
  }

  Future<void> callApi() async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      await context.read<AddressProvider>().getCities(
            false,
            context,
            setState,
            false,
            widget.index,
          );
      if (false! &&
          context.read<CartProvider>().addressList[widget.index!].cityId !=
              '0') {
        context.read<AddressProvider>().getZipcode(
            context.read<CartProvider>().addressList[widget.index!].cityId,
            true,
            false,
            context,
            setState,
            false,
            widget.index);
      }
    } else {
      Future.delayed(const Duration(seconds: 2)).then(
        (_) async {
          if (mounted) {
            setState(
              () {
                isNetworkAvail = false;
              },
            );
          }
        },
      );
    }
  }

  void _pincodeCheck() {
    showModalBottomSheet<dynamic>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(circularBorderRadius25),
          topRight: Radius.circular(circularBorderRadius25),
        ),
      ),
      builder: (builder) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.9,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 30,
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Form(
                    key: _formkey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  getTranslated(
                                    context,
                                    'CHECK_PRODUCT_AVAILABILITY',
                                  ),
                                  style: const TextStyle(
                                    fontFamily: 'ubuntu',
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Routes.pop(context);
                                },
                                child: const Icon(
                                  Icons.close,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(),
                        context
                                .read<AppSettingsCubit>()
                                .isCityWiseDeliverability()
                            ? TextFormField(
                                readOnly: true,
                                controller: curcity,
                                // onTap:  cityDialog(),
                                onTap: () {
                                  cityDialog();
                                },
                                textAlignVertical: TextAlignVertical.center,
                                // keyboardType: TextInputType.number,
                                textCapitalization: TextCapitalization.words,
                                validator: (val) =>
                                    StringValidation.validatePincode(
                                  val!,
                                  getTranslated(
                                    context,
                                    'CITY_REQUIRED',
                                  ),
                                ),
                                onSaved: (String? value) {
                                  if (value != null) curcity.text = value;
                                },
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .fontColor,
                                    ),
                                maxLength: 10,
                                decoration: InputDecoration(
                                  isDense: false,
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .lightBlack,
                                    ),
                                  ),
                                  counterText: '',
                                  prefixIcon: const Icon(
                                    Icons.location_on,
                                    size: 20,
                                  ),
                                  hintText: getTranslated(context, 'CITY_LBL'),
                                  hintStyle: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor
                                            .withOpacity(0.8),
                                      ),
                                  suffix: GestureDetector(
                                    onTap: () async {
                                      if (validateAndSave()) {
                                        if (IS_SHIPROCKET_ON == '1') {
                                          validatePinFromShipRocket(
                                              curcity.text, true, true);
                                        } else {
                                          validatePin(curcity.text, false, true,
                                              isCityName: context
                                                  .read<AppSettingsCubit>()
                                                  .isCityWiseDeliverability());
                                        }
                                      }
                                    },
                                    child: Text(
                                      getTranslated(context, 'Check'),
                                      style: const TextStyle(
                                        color: colors.primary,
                                        fontFamily: 'ubuntu',
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : TextFormField(
                                textAlignVertical: TextAlignVertical.center,
                                // keyboardType: TextInputType.number,
                                textCapitalization: TextCapitalization.words,
                                validator: (val) =>
                                    StringValidation.validatePincode(
                                  val!,
                                  getTranslated(
                                    context,
                                    'PIN_REQUIRED',
                                  ),
                                ),
                                onSaved: (String? value) {
                                  if (value != null) curPin = value;
                                },
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .fontColor,
                                    ),
                                maxLength: 10,
                                decoration: InputDecoration(
                                  isDense: false,
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .lightBlack,
                                    ),
                                  ),
                                  counterText: '',
                                  prefixIcon: const Icon(
                                    Icons.location_on,
                                    size: 20,
                                  ),
                                  hintText:
                                      getTranslated(context, 'PINCODEHINT_LBL'),
                                  hintStyle: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor
                                            .withOpacity(0.8),
                                      ),
                                  suffix: GestureDetector(
                                    onTap: () async {
                                      if (validateAndSave()) {
                                        if (IS_SHIPROCKET_ON == '1') {
                                          validatePinFromShipRocket(
                                              curPin, true, true);
                                        } else {
                                          validatePin(curPin, false, true,
                                              isCityName: context
                                                  .read<AppSettingsCubit>()
                                                  .isCityWiseDeliverability());
                                        }
                                      }
                                    },
                                    child: Text(
                                      getTranslated(context, 'Check'),
                                      style: const TextStyle(
                                        color: colors.primary,
                                        fontFamily: 'ubuntu',
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;

    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  addAndRemoveQty(String qty, int from, int totalLen, int itemCounter) {
    Product model = widget.model!;

    if (context.read<UserProvider>().userId != '') {
      if (from == 1) {
        if (int.parse(qty) >= totalLen) {
          qtyController.text = totalLen.toString();
          context.read<ProductDetailProvider>().qtyChange = true;
          setSnackbar("${getTranslated(context, 'MAXQTY')}  $qty", context);
        } else {
          qtyController.text = (int.parse(qty) + (itemCounter)).toString();
          context.read<ProductDetailProvider>().qtyChange = true;
        }
      } else if (from == 2) {
        if (int.parse(qty) <= model.minOrderQuntity!) {
          qtyController.text = itemCounter.toString();
          context.read<ProductDetailProvider>().qtyChange = true;
        } else {
          qtyController.text = (int.parse(qty) - itemCounter).toString();
          context.read<ProductDetailProvider>().qtyChange = true;
        }
      } else {
        qtyController.text = qty;
        context.read<ProductDetailProvider>().qtyChange = true;
      }
      context.read<CartProvider>().setProgress(false);
      setState(() {});
    } else {
      if (from == 1) {
        if (int.parse(qty) >= totalLen) {
          qtyController.text = totalLen.toString();
          setSnackbar("${getTranslated(context, 'MAXQTY')}  $qty", context);
        } else {
          qtyController.text = (int.parse(qty) + (itemCounter)).toString();
          context.read<ProductDetailProvider>().qtyChange = true;
        }
      } else if (from == 2) {
        if (int.parse(qty) <= model.minOrderQuntity!) {
          qtyController.text = itemCounter.toString();
          context.read<ProductDetailProvider>().qtyChange = true;
        } else {
          qtyController.text = (int.parse(qty) - itemCounter).toString();
          context.read<ProductDetailProvider>().qtyChange = true;
        }
      } else {
        qtyController.text = qty;
        context.read<ProductDetailProvider>().qtyChange = true;
      }
      context.read<CartProvider>().setProgress(false);
      setState(
        () {},
      );
    }
  }

  cartTotalClear() {
    context.read<CartProvider>().totalPrice = 0;
    context.read<CartProvider>().taxPer = 0;
    context.read<CartProvider>().deliveryCharge = 0;
    context.read<CartProvider>().addressList.clear();
    context.read<CartProvider>().promoAmt = 0;
    context.read<CartProvider>().remWalBal = 0;
    context.read<CartProvider>().usedBalance = 0;
    context.read<CartProvider>().payMethod = null;
    context.read<CartProvider>().isPromoValid = false;
    context.read<CartProvider>().isPromoLen = false;
    context.read<CartProvider>().isUseWallet = false;
    context.read<CartProvider>().isPayLayShow = true;
    context.read<CartProvider>().selectedMethod = null;
    context.read<CartProvider>().selectedTime = null;
    context.read<CartProvider>().selectedDate = null;
    context.read<CartProvider>().selAddress = '';
    context.read<CartProvider>().selTime = '';
    context.read<CartProvider>().selDate = '';
    context.read<CartProvider>().promocode = '';
  }

  Future<void> addToCart(
    String qty,
    bool intent,
    bool from,
    Product product,
  ) async {
    if (qty == '') {
      qty = '1';
    }
    try {
      isNetworkAvail = await isNetworkAvailable();
      if (isNetworkAvail) {
        setState(
          () {
            context.read<ProductDetailProvider>().qtyChange = true;
          },
        );
        if (context.read<UserProvider>().userId != '') {
          try {
            if (mounted) {
              setState(
                () {
                  context.read<CartProvider>().setProgress(true);
                },
              );
            }

            Product model = widget.model!;

            if (int.parse(qty) < model.minOrderQuntity!) {
              qty = model.minOrderQuntity.toString();
              setSnackbar(
                "${getTranslated(context, 'MIN_MSG')}$qty",
                context,
              );
            }
            var parameter = {
              // USER_ID: context.read<UserProvider>().userId,
              PRODUCT_VARIENT_ID:
                  model.prVarientList![selectedProductVariantIndex].id,
              QTY: qty,
            };

            ApiBaseHelper().postAPICall(manageCartApi, parameter).then(
              (getdata) {
                bool error = getdata['error'];
                String? msg = getdata['message'];

                if (msg ==
                    getTranslated(context,
                        'Only single seller items are allow in cart.You can remove privious item(s) and add this item.')) {
                  confirmDialog();
                }
                if (!error) {
                  var data = getdata['data'];
                  widget.model!.prVarientList![selectedProductVariantIndex]
                      .cartCount = qty.toString();
                  if (from) {
                    context
                        .read<UserProvider>()
                        .setCartCount(data['cart_count']);
                    var cart = getdata['cart'];
                    if (cart is List) {
                      List<SectionModel> cartList = [];
                      cartList = (cart as List)
                          .map((cart) => SectionModel.fromCart(cart))
                          .toList();
                      context.read<CartProvider>().setCartlist(cartList);
                    }
                    if (intent) {
                      //context.read<UserProvider>().setCartCount('');
                      cartTotalClear();
                      Routes.navigateToCartScreen(context, false,
                          isFromCart: widget.fromCart);
                    }
                  }
                } else {
                  if (msg !=
                      getTranslated(context,
                          'Only single seller items are allow in cart.You can remove privious item(s) and add this item.')) {
                    setSnackbar(msg!, context);
                  }
                }
                if (mounted) {
                  setState(
                    () {
                      context.read<CartProvider>().setProgress(false);
                    },
                  );
                }

                if (msg == 'Cart Updated !') {
                  setSnackbar(
                      getTranslated(context, 'PRODUCT_ADDED_TO_CART_LBL'),
                      context);
                }
              },
              onError: (error) {
                setSnackbar(error.toString(), context);
              },
            );
          } on TimeoutException catch (_) {
            setSnackbar(getTranslated(context, 'somethingMSg'), context);
            if (mounted) {
              setState(
                () {
                  context.read<CartProvider>().setProgress(false);
                },
              );
            }
          }
        } else {
          if (singleSellerOrderSystem) {
            if (CurrentSellerID == '' ||
                CurrentSellerID == widget.model!.seller_id!) {
              context
                  .read<SettingProvider>()
                  .setCurrentSellerID(widget.model!.seller_id!);
              CurrentSellerID = widget.model!.seller_id!;
              List<Product>? prList = [];
              prList.add(widget.model!);
              context.read<CartProvider>().addCartItem(
                    SectionModel(
                      qty: qty,
                      productList: prList,
                      varientId: widget.model!
                          .prVarientList![selectedProductVariantIndex].id!,
                      id: widget.model!.id,
                    ),
                  );
              db.insertCart(
                widget.model!.id!,
                widget.model!.prVarientList![selectedProductVariantIndex].id!,
                qty,
                context,
              );
              setSnackbar(
                  getTranslated(context, 'PRODUCT_ADDED_TO_CART_LBL'), context);
              Future.delayed(const Duration(milliseconds: 100)).then(
                (_) async {
                  if (from && intent) {
                    cartTotalClear();

                    Routes.navigateToCartScreen(context, false,
                        isFromCart: widget.fromCart);
                  }
                },
              );
            } else {
              confirmDialog();
            }
          } else {
            List<Product>? prList = [];
            prList.add(widget.model!);
            context.read<CartProvider>().addCartItem(
                  SectionModel(
                    qty: qty,
                    productList: prList,
                    varientId: widget
                        .model!.prVarientList![selectedProductVariantIndex].id!,
                    id: widget.model!.id,
                  ),
                );
            db.insertCart(
              widget.model!.id!,
              widget.model!.prVarientList![selectedProductVariantIndex].id!,
              qty,
              context,
            );
            setSnackbar(
                getTranslated(context, 'PRODUCT_ADDED_TO_CART_LBL'), context);
            Future.delayed(const Duration(milliseconds: 100)).then(
              (_) async {
                if (from && intent) {
                  cartTotalClear();
                  Routes.navigateToCartScreen(context, false,
                      isFromCart: widget.fromCart);
                }
              },
            );
          }
        }
      } else {
        if (mounted) {
          setState(
            () {
              isNetworkAvail = false;
            },
          );
        }
      }
    } on FormatException catch (e) {
      setSnackbar(e.message, context);
    }
  }

  update() {
    setState(
      () {},
    );
  }

  void confirmDialog() {
    showGeneralDialog(
      barrierColor: Theme.of(context).colorScheme.black.withOpacity(0.5),
      transitionBuilder: (context, a1, a2, widget) {
        return Transform.scale(
          scale: a1.value,
          child: Opacity(
            opacity: a1.value,
            child: AlertDialog(
              contentPadding: const EdgeInsets.all(0),
              elevation: 2.0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(
                    circularBorderRadius5,
                  ),
                ),
              ),
              content: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SizedBox(
                  height: 110,
                  child: Column(
                    children: [
                      Text(
                        getTranslated(context,
                            'Your cart already has an items of another seller would you like to remove it ?'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.lightBlack,
                          fontSize: textFontSize14,
                          fontFamily: 'ubuntu',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: SvgPicture.asset(
                            DesignConfiguration.setSvgPath('appbarCart'),
                            colorFilter: const ColorFilter.mode(
                                colors.primary, BlendMode.srcIn),
                            height: 50,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    getTranslated(context, 'CANCEL'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.lightBlack,
                      fontSize: textFontSize15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ubuntu',
                    ),
                  ),
                  onPressed: () {
                    Routes.pop(context);
                  },
                ),
                TextButton(
                  child: Text(
                    getTranslated(context, 'Clear Cart'),
                    style: const TextStyle(
                      color: colors.primary,
                      fontSize: textFontSize15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'ubuntu',
                    ),
                  ),
                  onPressed: () {
                    if (context.read<UserProvider>().userId != '') {
                      context.read<UserProvider>().setCartCount('0');
                      context
                          .read<ProductDetailProvider>()
                          .clearCartNow(context)
                          .then(
                            (value) {},
                          );
                      Future.delayed(const Duration(seconds: 1)).then(
                        (_) {
                          if (context.read<ProductDetailProvider>().error ==
                              false) {
                            if (context
                                    .read<ProductDetailProvider>()
                                    .snackbarmessage ==
                                'Data deleted successfully') {
                              setSnackbar(
                                  getTranslated(
                                      context, 'Cart Clear successfully ...!'),
                                  context);
                            } else {
                              setSnackbar(
                                  context
                                      .read<ProductDetailProvider>()
                                      .snackbarmessage,
                                  context);
                            }
                          } else {
                            setSnackbar(
                                context
                                    .read<ProductDetailProvider>()
                                    .snackbarmessage,
                                context);
                          }
                          Routes.pop(context);
                        },
                      );
                    } else {
                      context.read<SettingProvider>().setCurrentSellerID('');
                      CurrentSellerID = '';
                      db.clearCart();
                      context.read<UserProvider>().setCartCount('0');
                      cartTotalClear();
                      Routes.pop(context);
                    }
                  },
                )
              ],
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: false,
      barrierLabel: '',
      context: context,
      pageBuilder: (context, animation1, animation2) {
        return const SizedBox();
      },
    );
  }

  clearAll() {
    context.read<CartProvider>().totalPrice = 0;
    context.read<CartProvider>().oriPrice = 0;
    context.read<CartProvider>().taxPer = 0;
    context.read<CartProvider>().deliveryCharge = 0;
    context.read<CartProvider>().addressList.clear();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        context.read<CartProvider>().setCartlist([]);
        context.read<CartProvider>().setProgress(false);
      },
    );
    context.read<CartProvider>().promoAmt = 0;
    context.read<CartProvider>().remWalBal = 0;
    context.read<CartProvider>().usedBalance = 0;
    context.read<CartProvider>().payMethod = null;
    context.read<CartProvider>().isPromoValid = false;
    context.read<CartProvider>().isUseWallet = false;
    context.read<CartProvider>().isPayLayShow = true;
    context.read<CartProvider>().selectedMethod = null;
  }

  Future<void> getReview() async {
    try {
      isNetworkAvail = await isNetworkAvailable();
      if (isNetworkAvail) {
        try {
          var parameter = {
            PRODUCT_ID: widget.model!.id,
            LIMIT: perPage.toString(),
            OFFSET: context.read<ProductDetailProvider>().offset.toString(),
          };
          ApiBaseHelper().postAPICall(getRatingApi, parameter).then(
            (getdata) {
              bool error = getdata['error'];
              String? msg = getdata['message'];
              if (!error) {
                context.read<ProductDetailProvider>().total =
                    int.parse(getdata['total']);

                context.read<ProductDetailProvider>().star1 = getdata['star_1'];
                context.read<ProductDetailProvider>().star2 = getdata['star_2'];
                context.read<ProductDetailProvider>().star3 = getdata['star_3'];
                context.read<ProductDetailProvider>().star4 = getdata['star_4'];
                context.read<ProductDetailProvider>().star5 = getdata['star_5'];
                if ((context.read<ProductDetailProvider>().offset) <
                    context.read<ProductDetailProvider>().total) {
                  var data = getdata['data'];
                  context.read<ProductDetailProvider>().reviewList =
                      (data as List)
                          .map((data) => User.forReview(data))
                          .toList();

                  context.read<ProductDetailProvider>().offset =
                      context.read<ProductDetailProvider>().offset + perPage;
                }
              } else {
                if (msg != 'No ratings found !') setSnackbar(msg!, context);
              }
              if (mounted) {
                setState(
                  () {
                    context.read<ProductDetailProvider>().isLoading = false;
                  },
                );
              }
            },
            onError: (error) {
              setSnackbar(error.toString(), context);
            },
          );
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg'), context);
          if (mounted) {
            setState(
              () {
                context.read<ProductDetailProvider>().isLoading = false;
              },
            );
          }
        }
      } else {
        if (mounted) {
          setState(
            () {
              isNetworkAvail = false;
            },
          );
        }
      }
    } on FormatException catch (e) {
      setSnackbar(e.message, context);
    }
  }

  reset() {
    setState(() {});
  }

  _setFav(int index, int from) async {
    try {
      isNetworkAvail = await isNetworkAvailable();
      if (isNetworkAvail) {
        try {
          if (mounted) {
            setState(
              () {
                index == -1
                    ? widget.model!.isFavLoading = true
                    : from == 1
                        ? productList[index].isFavLoading = true
                        : mostFavProList[index].isFavLoading = true;
              },
            );
          }
          var parameter = {
            // USER_ID: context.read<UserProvider>().userId,
            PRODUCT_ID: from == 1 ? productList[index].id : widget.model!.id
          };
          ApiBaseHelper().postAPICall(setFavoriteApi, parameter).then(
            (getdata) {
              bool error = getdata['error'];
              String? msg = getdata['message'];
              if (!error) {
                index == -1
                    ? widget.model!.isFav = '1'
                    : from == 1
                        ? productList[index].isFav = '1'
                        : mostFavProList[index].isFav = '1';
                context
                    .read<FavoriteProvider>()
                    .addFavItem(from == 1 ? productList[index] : widget.model);
                setSnackbar(msg!, context);
              } else {
                setSnackbar(msg!, context);
              }

              if (mounted) {
                setState(
                  () {
                    index == -1
                        ? widget.model!.isFavLoading = false
                        : productList[index].isFavLoading = false;
                  },
                );
              }
            },
            onError: (error) {
              setSnackbar(error.toString(), context);
            },
          );
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg'), context);
        }
      } else {
        if (mounted) {
          setState(
            () {
              isNetworkAvail = false;
            },
          );
        }
      }
    } on FormatException catch (e) {
      setSnackbar(e.message, context);
    }
  }

  _removeFav(int index, int from) async {
    try {
      isNetworkAvail = await isNetworkAvailable();
      if (isNetworkAvail) {
        try {
          if (mounted) {
            setState(
              () {
                index == -1
                    ? widget.model!.isFavLoading = true
                    : from == 1
                        ? productList[index].isFavLoading = true
                        : mostFavProList[index].isFavLoading = true;
              },
            );
          }
          var parameter = {
            // USER_ID: context.read<UserProvider>().userId,
            PRODUCT_ID: from == 1 ? productList[index].id : widget.model!.id,
          };
          ApiBaseHelper().postAPICall(removeFavApi, parameter).then(
            (getdata) {
              bool error = getdata['error'];
              String? msg = getdata['message'];
              if (!error) {
                index == -1
                    ? widget.model!.isFav = '0'
                    : from == 1
                        ? productList[index].isFav = '1'
                        : mostFavProList[index].isFav = '1';
                context.read<FavoriteProvider>().removeFavItem(
                      from == 1
                          ? productList[index].prVarientList![0].id!
                          : widget.model!.prVarientList![0].id!,
                    );
                setSnackbar(msg!, context);
              } else {
                setSnackbar(msg!, context);
              }
              if (mounted) {
                setState(
                  () {
                    index == -1
                        ? widget.model!.isFavLoading = false
                        : from == 1
                            ? productList[index].isFavLoading = false
                            : mostFavProList[index].isFavLoading = false;
                  },
                );
              }
            },
            onError: (error) {
              setSnackbar(error.toString(), context);
            },
          );
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg'), context);
        }
      } else {
        if (mounted) {
          setState(
            () {
              isNetworkAvail = false;
            },
          );
        }
      }
    } on FormatException catch (e) {
      setSnackbar(e.message, context);
    }
  }

  getSilverAppBar(Product model) {
    return SliverAppBar(
      systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).colorScheme.white),
      expandedHeight: MediaQuery.of(context).size.height * 0.40,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.white,
      stretch: true,
      leading: Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1a0400ff),
                  offset: Offset(0, 0),
                  blurRadius: 30,
                )
              ],
              color: Theme.of(context).colorScheme.white,
              borderRadius: BorderRadius.circular(circularBorderRadius7),
            ),
            width: 33,
            height: 33,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: Theme.of(context).colorScheme.fontColor,
              ),
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(
            right: 10.0,
            bottom: 10.0,
            top: 10.0,
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                circularBorderRadius7,
              ),
              color: Theme.of(context).colorScheme.white,
            ),
            width: 33,
            height: 33,
            child: Center(
              child: IconButton(
                icon: const Icon(
                  Icons.share,
                  size: 20.0,
                  color: colors.primary,
                ),
                onPressed: () {
                  createDynamicLink();
                },
              ),
            ),
          ),
        ),
        Selector<UserProvider, String>(
          builder: (context, data, child) {
            return Padding(
              padding: const EdgeInsets.only(
                right: 10.0,
                bottom: 10.0,
                top: 10.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(circularBorderRadius7),
                  color: Theme.of(context).colorScheme.white,
                ),
                width: 33,
                height: 33,
                child: IconButton(
                  icon: Stack(
                    children: [
                      Center(
                        child: SvgPicture.asset(
                          DesignConfiguration.setSvgPath('appbarCart'),
                          colorFilter: const ColorFilter.mode(
                              colors.primary, BlendMode.srcIn),
                        ),
                      ),
                      (data != '' && data.isNotEmpty && data != '0')
                          ? Positioned(
                              bottom: 5,
                              right: 5,
                              child: Container(
                                height: 20,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colors.primary,
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(3),
                                    child: Text(
                                      data,
                                      style: TextStyle(
                                        fontSize: textFontSize8,
                                        fontFamily: 'ubuntu',
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Theme.of(context).colorScheme.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox()
                    ],
                  ),
                  onPressed: () {
                    cartTotalClear();
                    Routes.navigateToCartScreen(context, false,
                        isFromCart: widget.fromCart);
                  },
                ),
              ),
            );
          },
          selector: (_, HomePageProvider) => HomePageProvider.curCartCount,
        ),
        Selector<FavoriteProvider, List<String?>>(
          builder: (context, data, child) {
            return Padding(
              padding: const EdgeInsets.only(
                right: 10.0,
                bottom: 10.0,
                top: 10.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(circularBorderRadius7),
                  color: Theme.of(context).colorScheme.white,
                ),
                width: 33,
                height: 33,
                child: InkWell(
                  onTap: () {
                    if (context.read<UserProvider>().userId != '') {
                      !data.contains(widget.model!.id)
                          ? _setFav(-1, -1)
                          : _removeFav(-1, -1);
                    } else {
                      if (!data.contains(widget.model!.id)) {
                        widget.model!.isFavLoading = true;
                        widget.model!.isFav = '1';
                        context
                            .read<FavoriteProvider>()
                            .addFavItem(widget.model);
                        db.addAndRemoveFav(widget.model!.id!, true);
                        widget.model!.isFavLoading = false;
                        setSnackbar(getTranslated(context, 'Added to favorite'),
                            context);
                      } else {
                        widget.model!.isFavLoading = true;
                        widget.model!.isFav = '0';
                        context
                            .read<FavoriteProvider>()
                            .removeFavItem(widget.model!.prVarientList![0].id!);
                        db.addAndRemoveFav(widget.model!.id!, false);
                        widget.model!.isFavLoading = false;
                        setSnackbar(
                            getTranslated(context, 'Removed from favorite'),
                            context);
                      }
                      setState(
                        () {},
                      );
                    }
                  },
                  child: Icon(
                    !data.contains(widget.model!.id)
                        ? Icons.favorite_border
                        : Icons.favorite,
                    size: 20,
                    color: colors.primary,
                  ),
                ),
              ),
            );
          },
          selector: (_, provider) => provider.favIdList,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _slider(),
      ),
    );
  }

  _showContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: <Widget>[
              getSilverAppBar(widget.model!),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          color: Theme.of(context).colorScheme.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              widget.model!.brandName != '' &&
                                      widget.model!.brandName != null
                                  ? GetNameWidget(
                                      name: widget.model!.brandName!,
                                    )
                                  : const SizedBox(),
                              GetTitleWidget(
                                title: widget.model!.name!,
                              ),
                              loading
                                  ? SizedBox.shrink()
                                  : widget.model!.availability != '0'
                                      ? GetPrice(
                                          pos: selectedProductVariantIndex,
                                          from: true,
                                          model: widget.model)
                                      : GetPrice(
                                          pos: selectedProductVariantIndex,
                                          from: false,
                                          model: widget.model,
                                        ),
                              const GetIncludeTaxWidget(),
                              GetRatttingWidget(
                                ratting: widget.model!.rating!,
                                noOfRatting: widget.model!.noOfRating!,
                              ),
                              // product statestics widget will continue to show the 3 values
                              loading
                                  ? const SizedBox()
                                  : Container(
                                      constraints:
                                          const BoxConstraints(maxHeight: 30),
                                      child: Builder(builder: (context) {
                                        return ProductStatesticsAnimatedContainer(
                                            key: ValueKey(
                                                selectedProductVariantIndex),
                                            statistics: widget
                                                .model!
                                                .prVarientList![
                                                    selectedProductVariantIndex]
                                                .productStatistics!);
                                      }),
                                    ),
                              const SizedBox(
                                height: 5,
                              ),
                            ],
                          ),
                        ),
                        getDivider(2, context),
                        ProductHighLightsDetail(
                          model: widget.model,
                          update: update,
                        ),
                        attributes.isNotEmpty
                            ? getDivider(2, context)
                            : const SizedBox(),
                        attributes.isNotEmpty &&
                                widget.model!.type == 'variable_product'
                            ? getvariantPart()
                            : const SizedBox(),
                        getDivider(2, context),
                        context
                                .read<PromoCodeProvider>()
                                .promoCodeList
                                .isNotEmpty
                            ? SaveExtraWithOffers(
                                update: update,
                              )
                            : const SizedBox.shrink(),
                        context
                                .read<PromoCodeProvider>()
                                .promoCodeList
                                .isNotEmpty
                            ? getDivider(2, context)
                            : const SizedBox(),
                        ProductMoreDetail(
                          model: widget.model,
                          update: update,
                        ),
                        // getDivider(5, context),
                        DeliveryPinCode(
                          model: widget.model,
                          pincodeCheck: _pincodeCheck,
                          deliveryMsg: deliveryMsg,
                          deliveryDate: deliveryDate,
                          codDeliveryCharges: codDeliveryCharges,
                          prePaymentDeliveryCharges: prePaymentDeliveryCharges,
                        ),
                        CompareProduct(model: widget.model),
                        SellerDetail(model: widget.model),
                        // getDivider(5, context),
                        ChateWithSeller(model: widget.model),
                        SpeciExtraBtnDetails(model: widget.model),
                        // getDivider(5, context),
                        extraDesc(widget.model!, context),
                        context
                                .read<ProductDetailProvider>()
                                .reviewList
                                .isNotEmpty
                            ? getDivider(2, context)
                            : const SizedBox(),
                        ReviewWidget(
                          secPos: selectedProductVariantIndex,
                          widgetindex: widget.index,
                          model: widget.model,
                        ),
                        getDivider(2, context),
                        faqsQuesAndAns(),
                        getDivider(2, context),
                        _moreproduct(),
                        getDivider(2, context),
                        _mostFav()
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        loading
            ? SizedBox.shrink()
            : widget.model!.attributeList!.isEmpty
                ? widget.model!.availability != '0'
                    ? Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.white,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.black26,
                              blurRadius: 10,
                            )
                          ],
                        ),
                        child: AnimatedBuilder(
                            animation: buttonAnimationController,
                            builder: (context, child) {
                              return Consumer<CartProvider>(
                                builder: (context, value, child) => Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (value.cartList.any((element) =>
                                        element.varientId ==
                                        widget
                                            .model!
                                            .prVarientList![
                                                selectedProductVariantIndex]
                                            .id)) ...[
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            if (!context
                                                .read<CartProvider>()
                                                .isProgress) {
                                              Routes.navigateToCartScreen(
                                                  context, false,
                                                  isFromCart: widget.fromCart);
                                            }
                                          },
                                          child: Container(
                                            height: heightAnimation.value,
                                            decoration: const BoxDecoration(
                                              gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    colors.grad1Color,
                                                    colors.grad2Color
                                                  ],
                                                  stops: [
                                                    0,
                                                    1
                                                  ]),
                                            ),
                                            child: Center(
                                              child: Text(
                                                getTranslated(
                                                    context, 'VIEW_IN_CART'),
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium!
                                                    .copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .white,
                                                      fontSize: textFontSize16,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontFamily: 'ubuntu',
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ] else ...[
                                      Expanded(
                                        child: InkWell(
                                          onTap: () async {
                                            if (!context
                                                .read<CartProvider>()
                                                .isProgress) {
                                              addToCart(
                                                qtyController.text,
                                                false,
                                                true,
                                                widget.model!,
                                              );
                                            }
                                          },
                                          child: SizedBox(
                                            height: heightAnimation.value,
                                            child: Center(
                                              child: Text(
                                                getTranslated(
                                                    context, 'ADD_CART'),
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium!
                                                    .copyWith(
                                                      color: colors.primary,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontFamily: 'ubuntu',
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () async {
                                            if (!context
                                                .read<CartProvider>()
                                                .isProgress) {
                                              String qty;
                                              qty = qtyController.text;
                                              addToCart(
                                                qty,
                                                true,
                                                true,
                                                widget.model!,
                                              );
                                            }
                                          },
                                          child: Container(
                                            height: heightAnimation.value,
                                            decoration: const BoxDecoration(
                                              gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    colors.grad1Color,
                                                    colors.grad2Color
                                                  ],
                                                  stops: [
                                                    0,
                                                    1
                                                  ]),
                                            ),
                                            child: Center(
                                              child: Text(
                                                getTranslated(
                                                    context, 'BUYNOW'),
                                                textAlign: TextAlign.center,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium!
                                                    .copyWith(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .white,
                                                      fontSize: textFontSize16,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontFamily: 'ubuntu',
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ]
                                  ],
                                ),
                              );
                            }),
                      )
                    : AnimatedBuilder(
                        animation: buttonAnimationController,
                        builder: (context, child) {
                          return Container(
                            height: heightAnimation.value,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.black26,
                                  blurRadius: 10,
                                )
                              ],
                            ),
                            child: Center(
                              child: Text(
                                getTranslated(context, 'OUT_OF_STOCK_LBL'),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colors.red,
                                      fontFamily: 'ubuntu',
                                    ),
                              ),
                            ),
                          );
                        })
                : widget.model!.prVarientList![selectedProductVariantIndex]
                            .availability !=
                        '0'
                    ? Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.white,
                          boxShadow: [
                            BoxShadow(
                                color: Theme.of(context).colorScheme.black26,
                                blurRadius: 10)
                          ],
                        ),
                        child: Consumer<CartProvider>(
                          builder: (context, value, child) => Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (value.cartList.any((element) =>
                                  element.varientId ==
                                  widget
                                      .model!
                                      .prVarientList![
                                          selectedProductVariantIndex]
                                      .id)) ...[
                                Expanded(
                                  child: InkWell(
                                    onTap: () {
                                      if (!context
                                          .read<CartProvider>()
                                          .isProgress) {
                                        Routes.navigateToCartScreen(
                                            context, false,
                                            isFromCart: widget.fromCart);
                                      }
                                    },
                                    child: Container(
                                      height: heightAnimation.value,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              colors.grad1Color,
                                              colors.grad2Color
                                            ],
                                            stops: [
                                              0,
                                              1
                                            ]),
                                      ),
                                      child: Center(
                                        child: Text(
                                          getTranslated(
                                              context, 'VIEW_IN_CART'),
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .white,
                                                fontSize: textFontSize16,
                                                fontWeight: FontWeight.normal,
                                                fontFamily: 'ubuntu',
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ] else ...[
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      addToCart(
                                        qtyController.text,
                                        false,
                                        true,
                                        widget.model!,
                                      );
                                    },
                                    child: SizedBox(
                                      height: heightAnimation.value,
                                      child: Center(
                                        child: Text(
                                          getTranslated(context, 'ADD_CART'),
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                                color: colors.primary,
                                                fontWeight: FontWeight.normal,
                                                fontFamily: 'ubuntu',
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () async {
                                      String qty;
                                      qty = qtyController.text;
                                      addToCart(
                                        qty,
                                        true,
                                        true,
                                        widget.model!,
                                      );
                                    },
                                    child: Container(
                                      height: heightAnimation.value,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              colors.grad1Color,
                                              colors.grad2Color
                                            ],
                                            stops: [
                                              0,
                                              1
                                            ]),
                                      ),
                                      child: Center(
                                        child: Text(
                                          getTranslated(context, 'BUYNOW'),
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .white,
                                                fontSize: textFontSize16,
                                                fontWeight: FontWeight.normal,
                                                fontFamily: 'ubuntu',
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ))
                    : widget.model!.prVarientList![selectedProductVariantIndex]
                                .availability ==
                            '0'
                        ? AnimatedBuilder(
                            animation: buttonAnimationController,
                            builder: (context, child) {
                              return Container(
                                height: heightAnimation.value,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Theme.of(context).colorScheme.black26,
                                      blurRadius: 10,
                                    )
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    getTranslated(context, 'OUT_OF_STOCK_LBL'),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge!
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                          fontFamily: 'ubuntu',
                                        ),
                                  ),
                                ),
                              );
                            })
                        : const SizedBox()
      ],
    );
  }

  _moreproduct() {
    return productList.isNotEmpty
        ? Container(
            decoration:
                BoxDecoration(color: Theme.of(context).colorScheme.white),
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                      start: 12.0, end: 15.0, bottom: 10),
                  child: Text(
                    getTranslated(context, 'MORE_PRODUCT'),
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Theme.of(context).colorScheme.fontColor,
                          fontFamily: 'ubuntu',
                        ),
                  ),
                ),
                Container(
                  height: 230,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                        getProduct();
                      }
                      return true;
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: (notificationoffset < totalProduct)
                          ? productList.length + 1
                          : productList.length,
                      itemBuilder: (context, index) {
                        return (index == productList.length &&
                                !notificationisloadmore)
                            ? const SimmerSingle()
                            : ProductItemView(
                                setFav: () => _setFav(index, 1),
                                setState: reset,
                                removeFav: () => _removeFav(index, 1),
                                index: index,
                                productList: productList,
                                from: heroTagUniqueString,
                                valueofsetfav: 1,
                              );
                        // : productItem(index, 1);
                      },
                    ),
                  ),
                )
              ],
            ),
          )
        : const SizedBox();
  }

  _mostFav() {
    return mostFavProList.isNotEmpty
        ? Container(
            decoration:
                BoxDecoration(color: Theme.of(context).colorScheme.white),
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                      start: 12.0, end: 15.0, bottom: 10),
                  child: Text(
                    getTranslated(context, 'You are looking for'),
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Theme.of(context).colorScheme.fontColor,
                          fontFamily: 'ubuntu',
                        ),
                  ),
                ),
                Container(
                  height: 230,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: mostFavProList.length,
                    itemBuilder: (context, index) {
                      return ProductItemView(
                        setFav: () => _setFav(index, 1),
                        setState: reset,
                        removeFav: () => _removeFav(index, 1),
                        index: index,
                        productList: mostFavProList,
                        from: heroTagUniqueStringForMoreProductList,
                        valueofsetfav: 1,
                      );
                    },
                  ),
                ),
              ],
            ),
          )
        : const SizedBox();
  }

  faqsQuesAndAns() {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0),
      child: Container(
        color: Theme.of(context).colorScheme.white,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(
            start: 15,
            end: 15,
            bottom: 20,
            top: 15,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: deviceWidth,
                child: Text(
                  getTranslated(context, 'Customer Questions'),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.black,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Ubuntu',
                    fontStyle: FontStyle.normal,
                    fontSize: textFontSize16,
                  ),
                ),
              ),

              if (context
                  .read<ProductDetailProvider>()
                  .faqsProductList
                  .isNotEmpty)
                const FaqsQueWidget(),
              // if (context.read<ProductDetailProvider>().faqsProductList.length >
              //         1 ||
              //     context.read<UserProvider>().userId != '')
              const Divider(),
              // context.read<UserProvider>().userId != ''
              // ? context
              //             .read<ProductDetailProvider>()
              //             .faqsProductList.isNotEmpty
              //     ? const SizedBox()
              PostQuesWidget(model: widget.model, update: update),
              // : const SizedBox(),
              if (context.read<ProductDetailProvider>().faqsProductList.length >
                  1)
                AllQuesBtn(id: widget.model!.id)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttributeValueItem(
    Attribute attribute,
    int index,
    AttributeSelection attributeSelection,
  ) {
    return CustomSelectionContainer(
      radius: attribute.isColorType(index) ? 25 : 4,
      title: attribute.getValue(index),
      isSelected: attributeSelection.selectedId == attribute.getId(index),
      customChild: attribute.isImageType(index)
          ? Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(circularBorderRadius4),
              ),
              clipBehavior: Clip.antiAlias,
              child: DesignConfiguration.getCacheNotworkImage(
                boxFit: extendImg ? BoxFit.cover : BoxFit.contain,
                context: context,
                heightvalue: 45,
                widthvalue: 45,
                placeHolderSize: 45,
                imageurlString: attribute.getSValue(index),
              ),
            )
          : attribute.isColorType(index)
              ? Container(
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(
                    color: attribute.getColorValue(index),
                    shape: BoxShape.circle,
                  ),
                )
              : null,
      onTap: () {
        attributeSelection.selectedId = attribute.getId(index);
        selectedProductVariantIndex = getSelectedVariantIndex();
        if (widget.model!.prVarientList?[selectedProductVariantIndex].images !=
                null &&
            widget.model!.prVarientList![selectedProductVariantIndex].images!
                .isNotEmpty) {
          try {
            int? index;
            index = sliderList.indexWhere((element) =>
                element ==
                widget.model!.prVarientList?[selectedProductVariantIndex]
                    .images![0]);
            if (index != -1) {
              _pageController.animateToPage(index,
                  duration: const Duration(seconds: 1), curve: Curves.easeIn);
            }
          } catch (_) {}
        }
        setState(() {});
      },
    );
  }

  Widget _buildSingleAttribute(AttributeSelection attributeSelection) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          attributeSelection.oneAttributeList.name ?? "",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Theme.of(context).colorScheme.fontColor,
            fontFamily: 'ubuntu',
            fontSize: textFontSize14,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          runAlignment: WrapAlignment.start,
          children: List.generate(
            attributeSelection.oneAttributeList.getIdList().length,
            (index) => _buildAttributeValueItem(
                attributeSelection.oneAttributeList, index, attributeSelection),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  int getSelectedVariantIndex() {
    List<String> selectedAttributeIds =
        attributes.map((e) => e.selectedId.trim()).toList();
    int variantIndex = 0;

    for (int j = 0; j < widget.model!.prVarientList!.length; j++) {
      final variant = widget.model!.prVarientList![j];
      bool areAllThere = false;
      for (int i = 0; i < selectedAttributeIds.length; i++) {
        if (variant.attribute_value_ids!
            .split(',')
            .map((e) => e.trim())
            .toList()
            .contains(selectedAttributeIds[i])) {
          areAllThere = true;
        } else {
          areAllThere = false;
          break;
        }
      }
      if (areAllThere) {
        variantIndex = j;
        break;
      }
    }
    return variantIndex;
  }

  getvariantPart() {
    return attributes.isEmpty
        ? const SizedBox.shrink()
        : Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
              child: Column(
                children: [
                  ...List.generate(attributes.length, (index) {
                    return _buildSingleAttribute(attributes[index]);
                  })

                  // else ...[
                  //   ...List.generate(attributes.length, (index) {
                  //     return _buildSimpleAttribute(attributes[index]);
                  //   })
                  // ],
                ],
              ),
            ),
          );
  }

  Future getProduct() async {
    try {
      isNetworkAvail = await isNetworkAvailable();
      if (isNetworkAvail) {
        try {
          if (notificationisloadmore) {
            if (mounted) {
              setState(
                () {
                  notificationisloadmore = false;
                  notificationisgettingdata = true;
                  if (notificationoffset == 0) {
                    productList = [];
                  }
                },
              );
            }

            var parameter = {
              CATID: widget.model!.categoryId,
              LIMIT: perPage.toString(),
              OFFSET: notificationoffset.toString(),
              ID: widget.model!.id,
              IS_SIMILAR: '1'
            };

            if (context.read<UserProvider>().userId != '') {
              // parameter[USER_ID] = context.read<UserProvider>().userId;
            }

            ApiBaseHelper().postAPICall(getProductApi, parameter).then(
                (getdata) {
              bool error = getdata['error'];
              notificationisgettingdata = false;
              if (notificationoffset == 0) notificationisnodata = error;
              if (!error) {
                totalProduct = int.parse(getdata['total']);
                if (mounted) {
                  Future.delayed(
                    Duration.zero,
                    () => setState(
                      () {
                        List mainlist = getdata['data'];

                        if (mainlist.isNotEmpty) {
                          List<Product> items = [];
                          List<Product> allitems = [];

                          items.addAll(mainlist
                              .map((data) => Product.fromJson(data))
                              .toList());

                          allitems.addAll(items);
                          for (Product item in items) {
                            productList.where((i) => i.id == item.id).map(
                              (obj) {
                                allitems.remove(item);
                                return obj;
                              },
                            ).toList();
                          }
                          productList.addAll(allitems);
                          notificationisloadmore = true;

                          notificationoffset = notificationoffset + perPage;
                        } else {
                          notificationisloadmore = false;
                        }
                      },
                    ),
                  );
                }
              } else {
                notificationisloadmore = false;
                if (mounted) {
                  setState(
                    () {},
                  );
                }
              }
            }, onError: (error) {
              setSnackbar(error.toString(), context);
            });
          }
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg'), context);
          if (mounted) {
            setState(
              () {
                notificationisloadmore = false;
              },
            );
          }
        }
      } else {
        if (mounted) {
          setState(
            () {
              isNetworkAvail = false;
            },
          );
        }
      }
    } on FormatException catch (e) {
      setSnackbar(e.message, context);
    }
  }

  Future<void> getProduct1() async {
    isNetworkAvail = await isNetworkAvailable();
    if (isNetworkAvail) {
      try {
        var parameter = {
          CATID: widget.model!.categoryId,
          ID: widget.model!.id,
          IS_SIMILAR: '1'
        };

        // if (navigatorKey.currentContext!.read<UserProvider>().userId != '') {
        //   parameter[USER_ID] =
        //       navigatorKey.currentContext!.read<UserProvider>().userId;
        // }

        ApiBaseHelper().postAPICall(getProductApi, parameter).then(
          (getdata) {
            bool error = getdata['error'];

            if (!error) {
              navigatorKey.currentContext!
                  .read<ProductDetailProvider>()
                  .setProTotal(
                    int.parse(
                      getdata['total'],
                    ),
                  );

              List mainlist = getdata['data'];

              if (mainlist.isNotEmpty) {
                List<Product> items = [];
                List<Product> allitems = [];
                productList1 = [];

                items.addAll(
                  mainlist.map((data) => Product.fromJson(data)).toList(),
                );

                allitems.addAll(items);

                for (Product item in items) {
                  productList1.where((i) => i.id == item.id).map(
                    (obj) {
                      allitems.remove(item);
                      return obj;
                    },
                  ).toList();
                }
                productList1.addAll(allitems);

                navigatorKey.currentContext!
                    .read<ProductDetailProvider>()
                    .setProductList(productList1);

                navigatorKey.currentContext!
                    .read<ProductDetailProvider>()
                    .setProOffset(
                      navigatorKey.currentContext!
                              .read<ProductDetailProvider>()
                              .offset +
                          perPage,
                    );
              }
            } else {
              if (mounted) {
                setState(
                  () {
                    navigatorKey.currentContext!
                        .read<ProductDetailProvider>()
                        .setProNotiLoading(false);
                  },
                );
              }
            }
          },
          onError: (error) {
            setSnackbar(error.toString(), navigatorKey.currentContext!);
          },
        );
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(navigatorKey.currentContext!, 'somethingMSg'),
            navigatorKey.currentContext!);
        if (mounted) {
          setState(
            () {
              navigatorKey.currentContext!
                  .read<ProductDetailProvider>()
                  .setProNotiLoading(false);
            },
          );
        }
      }
    } else {
      if (mounted) {
        setState(
          () {
            isNetworkAvail = false;
          },
        );
      }
    }
  }

  Future allApiAndFun() async {
    getProductFaqs();

    setState(() {});
  }

  playIcon() {
    return Align(
      alignment: Alignment.center,
      child: (widget.model!.videType != '' &&
              widget.model!.video!.isNotEmpty &&
              widget.model!.video != '')
          ? const Icon(
              Icons.play_circle_fill_outlined,
              color: colors.primary,
              size: 35,
            )
          : const SizedBox(),
    );
  }

  Future<void> validatePinFromShipRocket(
      String pin, bool wantsToPop, bool showMsg) async {
    try {
      isNetworkAvail = await isNetworkAvailable();
      if (isNetworkAvail) {
        try {
          context.read<CartProvider>().setProgress(true);
          var parameter = {
            DEL_PINCODE: pin,
            PRODUCT_VARIENT_ID:
                widget.model!.prVarientList![selectedProductVariantIndex].id,
          };
          apiBaseHelper
              .postAPICall(checkShipRocketChargesOnProduct, parameter)
              .then((getdata) {
            bool error = getdata['error'];
            String? msg = getdata['message'];

            if (error) {
              curPin = '';

              deliveryDate = '';
              codDeliveryCharges = '';
              prePaymentDeliveryCharges = '';
              //setSnackbar(msg!, context);
            } else {
              if (getdata['data'] != null) {
                //
                deliveryMsg = msg!;

                deliveryDate = getdata['data']['estimate_date'] ?? '';
                codDeliveryCharges =
                    getdata['data']['delivery_charge_with_cod'].toString();
                prePaymentDeliveryCharges =
                    getdata['data']['delivery_charge_without_cod'].toString();
                //
              } else {
                deliveryDate = '';
                codDeliveryCharges = '';
                prePaymentDeliveryCharges = '';
                deliveryMsg = msg!;
              }
              context.read<UserProvider>().setPincode(pin);
              //setSnackbar(msg, context);
              setState(() {});
            }
            if (showMsg) {
              setSnackbar(msg!, context);
            }
            context.read<CartProvider>().setProgress(false);
            if (wantsToPop) {
              Navigator.pop(context);
            }

            //setSnackbar(msg!, context);
          }, onError: (error) {
            context.read<CartProvider>().setProgress(false);
            setSnackbar(error.toString(), context);
          });
        } on TimeoutException catch (_) {
          context.read<CartProvider>().setProgress(false);
          setSnackbar(getTranslated(context, 'somethingMSg'), context);
        }
      } else {
        if (mounted) {
          setState(() {
            isNetworkAvail = false;
          });
        }
      }
    } on FormatException catch (e) {
      setSnackbar(e.message, context);
    }
  }

  Future<void> validatePin(String pin, bool first, bool showMsg,
      {bool isCityName = false}) async {
    try {
      isNetworkAvail = await isNetworkAvailable();
      if (isNetworkAvail) {
        try {
          var parameter = {
            if (!isCityName) ZIPCODE: pin,
            if (isCityName) CITY: pin,
            PRODUCT_ID: widget.model!.id,
          };
          ApiBaseHelper().postAPICall(checkDeliverableApi, parameter).then(
            (getdata) {
              bool error = getdata['error'];
              String? msg = getdata['message'];

              if (error) {
                curPin = '';
              } else {
                if (pin != context.read<UserProvider>().curPincode) {}
                context.read<UserProvider>().setPincode(pin);
              }
              if (!first) {
                Routes.pop(context);
                //setSnackbar(msg!, context);
              }
              if (showMsg) {
                setSnackbar(msg!, context);
              }
            },
            onError: (error) {
              setSnackbar(error.toString(), context);
            },
          );
        } on TimeoutException catch (_) {
          setSnackbar(getTranslated(context, 'somethingMSg'), context);
        }
      } else {
        if (mounted) {
          setState(
            () {
              isNetworkAvail = false;
            },
          );
        }
      }
    } on FormatException catch (e) {
      setSnackbar(e.message, context);
    }
  }

  Future<void> getDeliverable() async {
    String pin = context.read<UserProvider>().curPincode;
    if (pin != '') {
      if (IS_SHIPROCKET_ON == '1') {
        validatePinFromShipRocket(pin, false, false);
      } else {
        validatePin(pin, true, false,
            isCityName:
                context.read<AppSettingsCubit>().isCityWiseDeliverability());
      }
    }
  }
}
