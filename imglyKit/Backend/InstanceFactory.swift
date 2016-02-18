//
//  InstanceFactory.swift
//  imglyKit
//
//  Created by Carsten Przyluczky on 03/02/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

import Foundation

/**
  A singleton that is out to create objects. It is used within the SDK to
  create filters, views, viewcontrollers and such.
*/
@objc(IMGLYInstanceFactory) public class InstanceFactory: NSObject {
    private static let filterTypeToFilter: [FilterType: ResponseFilter.Type] = [
        .None: NoneFilter.self,
        .K1: K1Filter.self,
        .K2: K2Filter.self,
        .K6: K6Filter.self,
        .KDynamic: KDynamicFilter.self,
        .Fridge: FridgeFilter.self,
        .Breeze: BreezeFilter.self,
        .Orchid: OrchidFilter.self,
        .Chest: ChestFilter.self,
        .Front: FrontFilter.self,
        .Fixie: FixieFilter.self,
        .X400: X400Filter.self,
        .BW: BWFilter.self,
        .AD1920: AD1920Filter.self,
        .Lenin: LeninFilter.self,
        .Quozi: QuoziFilter.self,
        .Pola669: Pola669Filter.self,
        .PolaSX: PolaSXFilter.self,
        .Food: FoodFilter.self,
        .Glam: GlamFilter.self,
        .Celsius: CelsiusFilter.self,
        .Texas: TexasFilter.self,
        .Lomo: LomoFilter.self,
        .Goblin: GoblinFilter.self,
        .Sin: SinFilter.self,
        .Mellow: MellowFilter.self,
        .Soft: SoftFilter.self,
        .Blues: BluesFilter.self,
        .Elder: ElderFilter.self,
        .Sunset: SunsetFilter.self,
        .Evening: EveningFilter.self,
        .Steel: SteelFilter.self,
        .Seventies: SeventiesFilter.self,
        .HighContrast: HighContrastFilter.self,
        .BlueShadows: BlueShadowsFilter.self,
        .Highcarb: HighcarbFilter.self,
        .Eighties: EightiesFilter.self,
        .Colorful: ColorfulFilter.self,
        .Lomo100: Lomo100Filter.self,
        .Pro400: Pro400Filter.self,
        .Twilight: TwilightFilter.self,
        .CottonCandy: CottonCandyFilter.self,
        .Pale: PaleFilter.self,
        .Settled: SettledFilter.self,
        .Cool: CoolFilter.self,
        .Litho: LithoFilter.self,
        .Ancient: AncientFilter.self,
        .Pitched: PitchedFilter.self,
        .Lucid: LucidFilter.self,
        .Creamy: CreamyFilter.self,
        .Keen: KeenFilter.self,
        .Tender: TenderFilter.self,
        .Bleached: BleachedFilter.self,
        .BleachedBlue: BleachedBlueFilter.self,
        .Fall: FallFilter.self,
        .Winter: WinterFilter.self,
        .SepiaHigh: SepiaHighFilter.self,
        .Summer: SummerFilter.self,
        .Classic: ClassicFilter.self,
        .NoGreen: NoGreenFilter.self,
        .Neat: NeatFilter.self,
        .Plate: PlateFilter.self
    ]


    /**
    Creates a response filter with the specified type.

    - parameter type: The type of the filter that should be created.

    - returns: A CIFilter object that realizes the desired filter.
    */
    public class func effectFilterWithType(type: FilterType) -> EffectFilter {
        // swiftlint:disable force_cast
        return filterTypeToFilter[type]!.init() as! EffectFilter
        // swiftlint:enable force_cast
    }

    /**
    Creates a text filter.

    - returns: A text filter
    */
    public class func textFilter() -> TextFilter {
        return TextFilter()
    }

    /**
    Creates a sticker filter.

    - returns: A sticker filter
    */
    public class func stickerFilter() -> StickerFilter {
        return StickerFilter()
    }

    /**
    Creates a crop filter.

    - returns: A crop filter
    */
    public class func orientationCropFilter() -> OrientationCropFilter {
        return OrientationCropFilter()
    }

    /**
    Creates a tiltshift filter.

    - returns: A tiltshift filter.
    */
    public class func tiltShiftFilter() -> TiltshiftFilter {
        return TiltshiftFilter()
    }

    /**
     Creates a border filter.

     - returns: A border filter.
     */
    public class func borderFilter() -> BorderFilter {
        return BorderFilter()
    }

    /**
    Creates a color-adjustment filter.

    - returns: A color-adjustment filter.
    */
    public class func colorAdjustmentFilter() -> ContrastBrightnessSaturationFilter {
        return ContrastBrightnessSaturationFilter()
    }

    /**
    Creates an enhancement filter.

    - returns: A enhancement filter.
    */
    public class func enhancementFilter() -> EnhancementFilter {
        return EnhancementFilter()
    }

    /**
    Creates an scale filter.

    - returns: A scale filter.
    */
    public class func scaleFilter() -> ScaleFilter {
        return ScaleFilter()
    }

    /**
    Returns the list of filters, that should be available in the dialogs.
    Change this list to select the set of filters you want to present to the user.
    - returns: An array of filter types.
    */
    public class var availableFilterList: [FilterType] {
        return [
            .None, .K1, .K2, .K6, .KDynamic, .Fridge, .Breeze, .Orchid, .Chest, .Front, .Fixie,
            .X400, .BW, .AD1920, .Lenin, .Quozi, .Pola669, .PolaSX, .Food, .Glam, .Celsius, .Texas,
            .Lomo, .Goblin, .Sin, .Mellow, .Soft, .Blues, .Elder, .Sunset, .Evening, .Steel,
            .Seventies, .HighContrast, .BlueShadows, .Highcarb, .Eighties, .Colorful, .Lomo100,
            .Pro400, .Twilight, .CottonCandy, .Pale, .Settled, .Cool, .Litho, .Ancient, .Pitched,
            .Lucid, .Creamy, .Keen, .Tender, .Bleached, .BleachedBlue, .Fall, .Winter, .SepiaHigh,
            .Summer, .Classic, .NoGreen, .Neat, .Plate
        ]
    }

    // MARK: - Font Related

    /**
    Returns a list that determins what fonts will be available within
    the text-dialog.

    - returns: An array of fontnames.
    */
    public class var availableFontsList: [String] {
        return [
            "AmericanTypewriter",
            "Avenir-Heavy",
            "ChalkboardSE-Regular",
            "ArialMT",
            "KohinoorBangla-Regular",
            "Liberator",
            "Muncie",
            "AbrahamLincoln",
            "Airship27",
            "ArvilSans",
            "Bender-Inline",
            "Blanch-Condensed",
            "Cubano-Regular",
            "Franchise-Bold",
            "GearedSlab-Regular",
            "Governor",
            "Haymaker",
            "Homestead-Regular",
            "MavenProLight200-Regular",
            "MenschRegular",
            "Sullivan-Regular",
            "Tommaso",
            "ValenciaRegular",
            "Vevey"
        ]
    }

    /**
     Some font names are long and ugly therefor.
     In that case its possible to add an entry into this dictionary.
     The SDK will perform a lookup first and will use that name in the UI.

     - returns: A map to beautfy the names.
     */
    public class var fontDisplayNames: [String:String] {
        return [
            "AmericanTypewriter" : "Typewriter",
             "Avenir-Heavy" :"Avenir",
            "ChalkboardSE-Regular" : "Chalkboard",
            "ArialMT" : "Arial",
            "KohinoorBangla-Regular" : "Kohinoor",
            "AbrahamLincoln" : "Lincoln",
            "Airship27" : "Airship",
            "ArvilSans" : "Arvil",
            "Bender-Inline" : "Bender",
            "Blanch-Condensed" : "Blanch",
            "Cubano-Regular" : "Cubano",
            "Franchise-Bold" : "Franchise",
            "GearedSlab-Regular" : "Geared",
            "Homestead-Regular" : "Homestead",
            "MavenProLight200-Regular" : "Maven Pro",
            "MenschRegular" : "Mensch",
            "Sullivan-Regular" : "Sullivan",
            "ValenciaRegular" : "Valencia"
        ]
    }

    public class func fontImporter() -> FontImporter {
        return FontImporter()
    }

}
