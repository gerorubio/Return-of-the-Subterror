--Subterror Nemesis Sorcerer
--Scripted by Sorpresa37
local s,id=GetID()

function s.initial_effect(c)
	-- Recover Subterror card from GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.GyTargetToHand)
	e1:SetOperation(s.FromGyToHandOp)
	c:RegisterEffect(e1)
	-- Special Summon Subterror from deck by flipping face down a Subterror monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.FaceUpSubterrorTarget)
	e2:SetOperation(s.SpecialSummonSetOp)
	c:RegisterEffect(e2)
end

s.listed_series={SET_SUBTERROR}
s.listed_names={id}

-- Filters
function s.GyTarget(c)
	return c:IsSetCard(SET_SUBTERROR) and c:IsAbleToHand()
end

function s.FaceUpSubterrorMonster(c)
	return c:IsSetCard(SET_SUBTERROR) and c:IsFaceup() and c:IsCanTurnSet()
end

function s.SubterrorMonsterInDeck(c, e, tp)
	return c:IsSetCard(SET_SUBTERROR) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e, 0, tp, false, true)
end
--
function s.GyTargetToHand(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.GyTarget,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.FromGyToHandOp(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.GyTarget,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.FaceUpSubterrorTarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.FaceUpSubterrorMonster(chkc) end
	if chk ==  0 then
		return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 -- There is space to special summon
			and Duel.IsExistingMatchingCard(s.FaceUpSubterrorMonster, tp, LOCATION_MZONE, 0, 1, nill) -- There is Subtteror monsteer in deck to special summon
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectTarget(tp,s.FaceUpSubterrorMonster, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, nil)
	Duel.SetOperationInfo(0, CATEGORY_POSITION, g, 1, 0, 0)
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK)
end

function s.SpecialSummonSetOp(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		if Duel.ChangePosition(tc, POS_FACEDOWN_DEFENSE) ~= 0 then
			if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
			local g=Duel.SelectMatchingCard(tp, s.SubterrorMonsterInDeck, tp, LOCATION_DECK, 0, 1, 1, nil, e, tp)
			if #g>0 then
				Duel.SpecialSummon(g,0,tp,tp,false,true,POS_FACEDOWN_DEFENSE)
				Duel.ConfirmCards(1-tp,g)
			end
		end
	end
end