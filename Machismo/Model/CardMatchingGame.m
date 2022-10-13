//
//  CardMatchingGame.m
//  Machismo
//
//  Created by wellzhu on 2022/10/12.
//

#import "CardMatchingGame.h"

@interface CardMatchingGame()
@property (nonatomic, readwrite) NSInteger score;
@property (nonatomic, strong) NSMutableArray *cards; // of Card
@end

@implementation CardMatchingGame

- (NSMutableArray *)cards {
    if (!_cards) _cards = [[NSMutableArray alloc] init];
    return _cards;
}

- (instancetype)initWithCardCount:(NSUInteger)count
                        usingDeck:(Deck *)deck {
    self = [super init];
    
    if (self) {
        for (int i = 0; i < count; i++) {
            Card *card = [deck drawRandomCard];
            if (card) {
                [self.cards addObject:card];
            } else {
                // 若deck里剩余的牌不够初始化，则返回nil
                self = nil;
                break;
            }
        }
    }
    
    return self;
}

// 使用index获取cards中的牌，可以避免crash
- (Card *)cardAtIndex:(NSUInteger)index {
    return (index < [self.cards count]) ? self.cards[index] : nil;
}

static const int MISMATCH_PENALTY = 2;
static const int MATCH_BONUS = 4;
static const int COST_TO_CHOOSE = 1;
- (void)chooseCardAtIndex:(NSUInteger)index {
    // 选择index卡牌
    Card *card = [self cardAtIndex:index];
    // 若卡牌未匹配过
    if (!card.isMatched) {
        // 若卡牌已选择，则取消选择，并翻面
        if (card.isChosen) {
            card.chosen = NO;
        } else {
            // 若卡牌未选择，和其他已选择的卡牌匹配
            for (Card *otherCard in self.cards) {
                //当前卡牌与其它已选择、未匹配的卡牌进行match
                if (otherCard.isChosen && !otherCard.isMatched) {
                    int matchScore = [card match:@[otherCard]];
                    if (matchScore) {
                        self.score += matchScore * MATCH_BONUS;
                        // 如果匹配成功，则将卡牌都设为匹配成功
                        otherCard.matched = YES;
                        card.matched = YES;
                    } else {
                        self.score -= MISMATCH_PENALTY;
                        // 为匹配的话其它卡牌则取消选择，并翻面
                        otherCard.chosen = NO;
                    }
                    break;
                }
            }
            self.score -= COST_TO_CHOOSE;
            card.chosen = YES;
        }
    }
}
@end