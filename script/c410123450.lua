--Subterror Nemesis Sorcerer
--Scripted by Sorpresa37
local s,id=GetID()

function s.initial_effect(c)
	-- FLIP: Recover Subterror card from GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.GyTargetToHand)
	e1:SetOperation(s.FromGyToHandOp)
	c:RegisterEffect(e1)

	-- Field: Special Summon Subterror from deck by flipping face down a Subterror monster
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

	-- Hand: Special Summon this card from your hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,{id, 2})
	e3:SetTarget(s.FaceDownSubterrorTarget)
	e3:SetOperation(s.SpecialSummonFromHand)
	c:RegisterEffect(e3)
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

function s.FaceDownSubterrorMonster(c)
	return c:IsSetCard(SET_SUBTERROR) and c:IsFacedown() and c:IsCanChangePosition()
end

function s.SubterrorMonsterInDeck(c, e, tp)
	return c:IsSetCard(SET_SUBTERROR) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e, 0, tp, false, true)
end

-- Targets and operations
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
		return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
			and Duel.IsExistingMatchingCard(s.FaceUpSubterrorMonster, tp, LOCATION_MZONE, 0, 1, nil)
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

function s.FaceDownSubterrorTarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.FaceDownSubterrorFilter(chkc) end
	local c=e:GetHandler()
	if chk == 0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE) > 0
			and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
			and Duel.IsExistingTarget(s.FaceDownSubterrorMonster, tp, LOCATION_MZONE, 0, 1, nil)
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp, s.FaceDownSubterrorMonster, tp, LOCATION_MZONE, 0, 1, 1, nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end

function s.SpecialSummonFromHand(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not (tc and tc:IsRelateToEffect(e)) then return end
	if Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)>0 then
		if tc:IsFacedown() and tc:IsCanChangePosition() then
			local pos=Duel.SelectPosition(tp, tc, POS_FACEUP_ATTACK+POS_FACEUP_DEFENSE)
			Duel.ChangePosition(tc, pos)
		end
	end
end