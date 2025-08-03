--Subterror Disruption
--Scripted by Sorpresa37
local s,id=GetID()
function s.initial_effect(c)
	-- Only on activation special summon Subterror in face down from deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.SpecialSummonFromDeckFaceDown)
	c:RegisterEffect(e1)
	-- When a monster is summoned flip face up a subterror monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_STZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.FaceDownSubterrorTarget)
	e2:SetOperation(s.ChangeToFaceUPSubterrorOp)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCountLimit(1,{id,1}) -- Check
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCountLimit(1,{id,1}) -- Check
	e4:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e4)
	-- When a monster is summoned flip face down a subterror monster
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_POSITION)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetRange(LOCATION_STZONE)
	e5:SetCountLimit(1,{id,1})
	e5:SetTarget(s.FaceUpSubterrorTarget)
	e5:SetOperation(s.ChangeToDownUPSubterrorOp)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCountLimit(1,{id,1}) -- Check
	e6:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCountLimit(1,{id,1}) -- Check
	e7:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e7)
end

s.listed_series={SET_SUBTERROR}
s.listed_names={id}

function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_SUBTERROR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.FaceDownSubterrorMonster(c)
	return c:IsSetCard(SET_SUBTERROR) and c:IsFacedown() and c:IsCanChangePosition()
end

function s.FaceUpSubterrorMonster(c)
	return c:IsSetCard(SET_SUBTERROR) and c:IsFaceup() and c:IsCanChangePosition()
end

function s.SpecialSummonFromDeckFaceDown(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		Duel.ConfirmCards(1-tp,sg)
	end
end

-- Effect 2
function s.FaceDownSubterrorTarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFacedown() end
	if chk==0 then return Duel.IsExistingTarget(s.FaceDownSubterrorMonster, tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectTarget(tp, s.FaceDownSubterrorMonster, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end

function s.ChangeToFaceUPSubterrorOp(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() and tc:IsCanChangePosition() then
		local pos=Duel.SelectPosition(tp, tc, POS_FACEUP_ATTACK+POS_FACEUP_DEFENSE)
		Duel.ChangePosition(tc, pos)
	end
end

function s.FaceUpSubterrorTarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(s.FaceUpSubterrorMonster, tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectTarget(tp, s.FaceUpSubterrorMonster, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end

function s.ChangeToDownUPSubterrorOp(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsCanChangePosition() then
		local pos=Duel.SelectPosition(tp, tc, POS_FACEDOWN_DEFENSE)
		Duel.ChangePosition(tc, pos)
	end
end