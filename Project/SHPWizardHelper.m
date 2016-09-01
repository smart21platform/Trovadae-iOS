//
//  SHPWizardHelper.m
//  San Vito dei Normanni
//
//  Created by Dario De pascalis on 18/07/14.
//
//

#import "SHPWizardHelper.h"
#import "SHPApplicationContext.h"
#import "SHPCategory.h"
#import "SHPConstants.h"


@implementation SHPWizardHelper

-(id)init {
    self = [super init];
    if (self) {
        self.dateToSendFormatter = [[NSDateFormatter alloc] init];
        [self.dateToSendFormatter setDateFormat:@"dd/MM/yyyy HH:mm Z"];
        [self.dateToSendFormatter setTimeZone:[NSTimeZone localTimeZone]];
    }
    return self;
}

+(NSMutableDictionary *)initializeWizardContext:(NSMutableDictionary *)wizardDictionary withTranslationsForCategory:(SHPCategory *)selectedCategory {
    // create wizard context
//    NSMutableDictionary *wizardDictionary = [[NSMutableDictionary alloc] init];
//    [applicationContext setVariable:WIZARD_DICTIONARY_KEY withValue:wizardDictionary];
    
    //[wizardDictionary setObject:self.scaledImage forKey:WIZARD_IMAGE_KEY];
    [wizardDictionary setObject:selectedCategory forKey:WIZARD_CATEGORY_KEY];
    [wizardDictionary setObject:selectedCategory forKey:WIZARD_ICON_CATEGORY_KEY];
    
    //        NSString *photo_hint_message = @"*Suggerimento*: Scegli una *bella* foto. Ricorda che una foto ben fatta invoglierà l’utente ad approfondire i dettagli.";
    //        NSString *description_hint_message = @"*Suggerimento*: Una buona descrizione deve essere originale e incuriosire.";
    //        NSString *title_hint_message = @"*Suggerimento*: Riassumi in un rigo la tua offerta.";
    //        NSString *poi_hint_message = @"Scegli un luogo tra quelli disponibili oppure creane uno nuovo.";
    //        NSString *data_hint_message =@"Inserisci la *data di inizio* e la *durata* dell'offerta.";
    
    NSLog(@"CATEGORY OID %@",selectedCategory.oid);
    
    NSLog(@"DEAL %@",selectedCategory.type );
    // TYPE: PHOTO
    if ([selectedCategory.type isEqualToString:CATEGORY_TYPE_PHOTO]) {
        
        // PHOTO
        [wizardDictionary setObject:NSLocalizedString(@"photo-step-top", nil) forKey:WIZARD_STEP_PHOTO_TOP_MESSAGE_KEY];
        [wizardDictionary setObject:NSLocalizedString(@"photo-step-hint", nil) forKey:WIZARD_STEP_PHOTO_HINT_MESSAGE_KEY];
        
        // DESCRIPTION
        [wizardDictionary setObject:NSLocalizedString(@"description-step-top", nil) forKey:WIZARD_STEP_DESCRIPTION_TOP_MESSAGE_KEY];
        [wizardDictionary setObject:NSLocalizedString(@"description-step-hint", nil) forKey:WIZARD_STEP_DESCRIPTION_HINT_MESSAGE_KEY];
        [wizardDictionary setObject:NSLocalizedString(@"description-step-example-type-photo", nil) forKey:WIZARD_STEP_DESCRIPTION_EXAMPLE_MESSAGE_KEY];
        
        // TITLE
        [wizardDictionary setObject:NSLocalizedString(@"title-step-top", nil) forKey:WIZARD_STEP_TITLE_TOP_MESSAGE_KEY];
        [wizardDictionary setObject:NSLocalizedString(@"title-step-hint", nil) forKey:WIZARD_STEP_TITLE_HINT_MESSAGE_KEY];
        [wizardDictionary setObject:NSLocalizedString(@"title-step-example-type-photo", nil) forKey:WIZARD_STEP_TITLE_EXAMPLE_MESSAGE_KEY];
        
        // DATE
        [wizardDictionary setObject:NSLocalizedString(@"date-step-top-type-deal", nil) forKey:WIZARD_STEP_DATE_TOP_MESSAGE_KEY];
        [wizardDictionary setObject:NSLocalizedString(@"date-step-hint", nil) forKey:WIZARD_STEP_DATE_HINT_MESSAGE_KEY];
        
        // POI
        [wizardDictionary setObject:NSLocalizedString(@"poi-step-top-type-photo", nil) forKey:WIZARD_STEP_POI_TOP_MESSAGE_KEY];
        [wizardDictionary setObject:NSLocalizedString(@"poi-step-hint", nil) forKey:WIZARD_STEP_POI_HINT_MESSAGE_KEY];
    }
    
    
    // TYPE: DEAL
    else if ([selectedCategory.type isEqualToString:CATEGORY_TYPE_DEAL]) {
        
        // PHOTO
        [wizardDictionary setObject:NSLocalizedString(@"photo-step-top-type-deal", nil) forKey:WIZARD_STEP_PHOTO_TOP_MESSAGE_KEY];
        [wizardDictionary setObject:NSLocalizedString(@"photo-step-hint", nil) forKey:WIZARD_STEP_PHOTO_HINT_MESSAGE_KEY];
        NSLog(@"DEAL");
        
        // DESCRIPTION
        [wizardDictionary setObject:NSLocalizedString(@"description-step-top-type-deal", nil) forKey:WIZARD_STEP_DESCRIPTION_TOP_MESSAGE_KEY];
        [wizardDictionary setObject:NSLocalizedString(@"description-step-hint", nil) forKey:WIZARD_STEP_DESCRIPTION_HINT_MESSAGE_KEY];
        [wizardDictionary setObject:NSLocalizedString(@"description-step-example-type-deal", nil) forKey:WIZARD_STEP_DESCRIPTION_EXAMPLE_MESSAGE_KEY];
        
        // TITLE
        [wizardDictionary setObject:NSLocalizedString(@"title-step-top", nil) forKey:WIZARD_STEP_TITLE_TOP_MESSAGE_KEY];
        [wizardDictionary setObject:NSLocalizedString(@"title-step-hint", nil) forKey:WIZARD_STEP_TITLE_HINT_MESSAGE_KEY];
        [wizardDictionary setObject:NSLocalizedString(@"title-step-example-type-deal", nil) forKey:WIZARD_STEP_TITLE_EXAMPLE_MESSAGE_KEY];
        // @"Menu di pesce e vino Doc"
        
        // POI
        [wizardDictionary setObject:NSLocalizedString(@"poi-step-top-type-deal", nil) forKey:WIZARD_STEP_POI_TOP_MESSAGE_KEY];
        [wizardDictionary setObject:NSLocalizedString(@"poi-step-hint-type-deal", nil) forKey:WIZARD_STEP_POI_HINT_MESSAGE_KEY];
        
        // DATE
        [wizardDictionary setObject:NSLocalizedString(@"date-step-top-type-deal", nil) forKey:WIZARD_STEP_DATE_TOP_MESSAGE_KEY];
        [wizardDictionary setObject:NSLocalizedString(@"date-step-hint", nil) forKey:WIZARD_STEP_DATE_HINT_MESSAGE_KEY];
        
        // PRICE
        [wizardDictionary setObject:NSLocalizedString(@"price-step-top", nil) forKey:WIZARD_STEP_PRICE_TOP_MESSAGE_KEY];
        [wizardDictionary setObject:NSLocalizedString(@"price-step-hint", nil) forKey:WIZARD_STEP_PRICE_HINT_MESSAGE_KEY];
    }
    
    
    // TYPE: MENU
    else if ([selectedCategory.type isEqualToString:CATEGORY_TYPE_MENU]) {
        //else if ([self.selectedCategory.oid hasPrefix:prefixMenu]) {
        // PHOTO
        [wizardDictionary setObject:NSLocalizedString(@"photo-step-top", nil) forKey:WIZARD_STEP_PHOTO_TOP_MESSAGE_KEY];
        [wizardDictionary setObject:NSLocalizedString(@"photo-step-hint", nil) forKey:WIZARD_STEP_PHOTO_HINT_MESSAGE_KEY];
        
        // DESCRIPTION
        [wizardDictionary setObject:NSLocalizedString(@"description-step-top", nil) forKey:WIZARD_STEP_DESCRIPTION_TOP_MESSAGE_KEY];
        [wizardDictionary setObject:NSLocalizedString(@"description-step-hint", nil) forKey:WIZARD_STEP_DESCRIPTION_HINT_MESSAGE_KEY];
        [wizardDictionary setObject:NSLocalizedString(@"description-step-example-type-menu", nil) forKey:WIZARD_STEP_DESCRIPTION_EXAMPLE_MESSAGE_KEY];
        // @"Linguine allo scoglio e con... cucinate ...#pescefresco #pasta #primopiatto #pesce #mare #spaghetti #calamari"
        
        // TITLE
        [wizardDictionary setObject:NSLocalizedString(@"title-step-top", nil) forKey:WIZARD_STEP_TITLE_TOP_MESSAGE_KEY];
        [wizardDictionary setObject:NSLocalizedString(@"title-step-hint", nil) forKey:WIZARD_STEP_TITLE_HINT_MESSAGE_KEY];
        [wizardDictionary setObject:NSLocalizedString(@"title-step-example-type-menu", nil) forKey:WIZARD_STEP_TITLE_EXAMPLE_MESSAGE_KEY];
        
        // POI
        [wizardDictionary setObject:NSLocalizedString(@"poi-step-top", nil) forKey:WIZARD_STEP_POI_TOP_MESSAGE_KEY];
        [wizardDictionary setObject:NSLocalizedString(@"poi-step-hint", nil) forKey:WIZARD_STEP_POI_HINT_MESSAGE_KEY];
        
        // DATE
        [wizardDictionary setObject:NSLocalizedString(@"date-step-top", nil) forKey:WIZARD_STEP_DATE_TOP_MESSAGE_KEY];
        [wizardDictionary setObject:NSLocalizedString(@"date-step-hint", nil) forKey:WIZARD_STEP_DATE_HINT_MESSAGE_KEY];
        
        // PRICE
        [wizardDictionary setObject:NSLocalizedString(@"price-step-top", nil) forKey:WIZARD_STEP_PRICE_TOP_MESSAGE_KEY];
        [wizardDictionary setObject:NSLocalizedString(@"price-step-hint-type-menu", nil) forKey:WIZARD_STEP_PRICE_HINT_MESSAGE_KEY];
    }
    
    // TYPE: COVER
    else if ([selectedCategory.type isEqualToString:CATEGORY_TYPE_COVER]) {
        
        // PHOTO
        [wizardDictionary setObject:NSLocalizedString(@"photo-step-top", nil) forKey:WIZARD_STEP_PHOTO_TOP_MESSAGE_KEY];
        [wizardDictionary setObject:NSLocalizedString(@"photo-step-hint", nil) forKey:WIZARD_STEP_PHOTO_HINT_MESSAGE_KEY];
        
        // DESCRIPTION
        [wizardDictionary setObject:NSLocalizedString(@"description-step-top", nil) forKey:WIZARD_STEP_DESCRIPTION_TOP_MESSAGE_KEY];
        [wizardDictionary setObject:NSLocalizedString(@"description-step-hint", nil) forKey:WIZARD_STEP_DESCRIPTION_HINT_MESSAGE_KEY];
        
        // POI
        [wizardDictionary setObject:NSLocalizedString(@"poi-step-top", nil) forKey:WIZARD_STEP_POI_TOP_MESSAGE_KEY];
        // @"Presso quale *B&B* o *struttura ricettiva* è disponibile questa offerta?"
        [wizardDictionary setObject:NSLocalizedString(@"poi-step-hint", nil) forKey:WIZARD_STEP_POI_HINT_MESSAGE_KEY];
        // @"Cerca una struttura tra quelle disponibili oppure creane una nuova."
        
    }
    
    // TYPE: EVENT
    else if ([selectedCategory.type isEqualToString:CATEGORY_TYPE_EVENT]) {
        //else if ([self.selectedCategory.oid rangeOfString:@"/event"].location != NSNotFound) {
        //else if ([self.selectedCategory.oid hasPrefix:@"/deal/event-deal"]) {
        
        // PHOTO
        [wizardDictionary setObject:NSLocalizedString(@"photo-step-top-type-event", nil) forKey:WIZARD_STEP_PHOTO_TOP_MESSAGE_KEY];
        // @"Scegli una *foto* rappresentativa dell'evento."
        [wizardDictionary setObject:NSLocalizedString(@"photo-step-hint", nil) forKey:WIZARD_STEP_PHOTO_HINT_MESSAGE_KEY];
        
        // DESCRIPTION
        [wizardDictionary setObject:NSLocalizedString(@"description-step-top", nil) forKey:WIZARD_STEP_DESCRIPTION_TOP_MESSAGE_KEY];
        [wizardDictionary setObject:NSLocalizedString(@"description-step-hint", nil) forKey:WIZARD_STEP_DESCRIPTION_HINT_MESSAGE_KEY];
        [wizardDictionary setObject:NSLocalizedString(@"description-step-example-type-event", nil) forKey:WIZARD_STEP_DESCRIPTION_EXAMPLE_MESSAGE_KEY];
        // @"Dalle 19:30 a Melpignano Concertone Finale \"La Notte Della Taranta\", Il più grande festival d'Italia e una delle più significative manifestazioni sulla cultura popolare in europa. #concerto #nottedellataranta #pizzica #musica #concertone #orchestra #livemusic #freeentry"
        
        // TITLE
        [wizardDictionary setObject:NSLocalizedString(@"title-step-top", nil) forKey:WIZARD_STEP_TITLE_TOP_MESSAGE_KEY];
        [wizardDictionary setObject:NSLocalizedString(@"title-step-hint", nil) forKey:WIZARD_STEP_TITLE_HINT_MESSAGE_KEY];
        [wizardDictionary setObject:NSLocalizedString(@"title-step-example-type-event", nil) forKey:WIZARD_STEP_TITLE_EXAMPLE_MESSAGE_KEY];
        
        // POI
        [wizardDictionary setObject:NSLocalizedString(@"poi-step-top-type-event", nil) forKey:WIZARD_STEP_POI_TOP_MESSAGE_KEY];
        // @"In quale *Città* o *Luogo* si svolge l'evento?"
        [wizardDictionary setObject:NSLocalizedString(@"poi-step-hint", nil) forKey:WIZARD_STEP_POI_HINT_MESSAGE_KEY];
        
        // DATE
        [wizardDictionary setObject:NSLocalizedString(@"date-step-top", nil) forKey:WIZARD_STEP_DATE_TOP_MESSAGE_KEY];
        // @"Quando?"
        [wizardDictionary setObject:NSLocalizedString(@"date-step-hint-type-event", nil) forKey:WIZARD_STEP_DATE_HINT_MESSAGE_KEY];
        // @"Inserisci la *data di inizio* e la *durata* dell'evento."
        
        // PRICE
        [wizardDictionary setObject:NSLocalizedString(@"price-step-top", nil) forKey:WIZARD_STEP_PRICE_TOP_MESSAGE_KEY];
        [wizardDictionary setObject:NSLocalizedString(@"price-step-hint-type-event", nil) forKey:WIZARD_STEP_PRICE_HINT_MESSAGE_KEY];
        // @"Indicare il prezzo in caso di evento non gratuito."
    }
    return wizardDictionary;
}

@end
