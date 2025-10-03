--Subterror Behemoth Ravinsoptera
--Scripted by Sorpresa37
local s,id=GetID()
function s.initial_effect(c)
	-- Fusion 2 Subterror monsters
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_SUBTERROR),2)

	-- Aternative Special Summon procedure
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon) -- Special Summon Condition
	e1:SetOperation(s.spop) -- Special Summon Operation
	e1:SetValue(SUMMON_TYPE_FUSION)
	c:RegisterEffect(e1)

	-- Flip effect: Add Subterror trap
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)

	-- Set and copy flip effect of subterror monster in GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,{id,2})
	e3:SetTarget(s.postg)
	e3:SetOperation(s.posop)
	c:RegisterEffect(e3)
end

s.listed_series={SET_SUBTERROR}

function s.FaceDownSubterrorMonster(c)
    return c:IsFacedown() and c:IsSetCard(SET_SUBTERROR)
end

function s.spcon(e, c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.CheckReleaseGroup(tp,s.FaceDownSubterrorMonster,1,false,1,true,c,tp,nil,false,nil, tp, c)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.SelectMatchingCard(tp, s.FaceDownSubterrorMonster, tp, LOCATION_MZONE, 0, 1, 1, nil, tp)
	Duel.Release(g,REASON_COST|REASON_MATERIAL)
	c:SetMaterial(g)
end

-- Effect 2
function s.thfilter(c)
	return c:IsSetCard(SET_SUBTERROR) and not c:IsCode(id) and c:IsAbleToHand() and c:IsTrapCard()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- Effect 3
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(id)==0 end
	c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD-RESET_TURN_SET|RESET_PHASE|PHASE_END,0,1)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end

function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end

function s.gyfilter(c)
	return c:IsSetCard(SET_SUBTERROR) and c:IsType(TYPE_FLIP) and c:IsMonster()
end

function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.gyfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.gyfilter,tp,LOCATION_GRAVE,0,1,nil) and c:IsCanTurnSet() end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.gyfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end

function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()

	print(tc)
	print('\n')

	if(tc:IsCode(16428514)) then -- Subterror Guru
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilterGuru,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
    end
	elseif tc:IsCode(92970404) then -- Subterror Behemoth Ultramafus
		local g=Duel.GetMatchingGroup(Card.IsCanTurnSet, tp, LOCATION_MZONE, LOCATION_MZONE, nil)
		g:RemoveCard(c)
    if #g>0 then
			Duel.ChangePosition(g, POS_FACEDOWN_DEFENSE)
    end
	elseif tc:IsCode(47556396) then -- Subterror Behemoth Speleogeist
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local g=Duel.SelectMatchingCard(tp, function(c) 
			return c:IsDefensePos() or c:GetAttack()>0 
    end, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, nil)
    local sc=g:GetFirst()
    if sc then
			if sc:IsDefensePos() then
				Duel.ChangePosition(sc, POS_FACEUP_ATTACK)
			end
			if sc:IsFaceup() then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_SET_ATTACK_FINAL)
				e1:SetValue(0)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				sc:RegisterEffect(e1)
			end
    end
	elseif tc:IsCode(78202553) then -- Subterror Behemoth Stalagmo
		print('\n')
	elseif tc:IsCode(21607304) then -- Subterror Behemoth Voltelluric
		print('\n')
	elseif tc:IsCode(1151281) then -- Subterror Behemoth Phospheroglacier
		print('\n')
	elseif tc:IsCode(42713844) then -- Subterror Behemoth Umastryx
		print('\n')
	elseif tc:IsCode(95218695) then -- Subterror Behemoth Dragossuary
		print('\n')
	elseif tc:IsCode(65976795) then -- Subterror Behemoth Stygokraken
		print('\n')
	elseif tc:IsCode(410123450) then -- Subterror Behemoth Sorcerer
		print('\n')
	end

	-- After resolving, Set Ravinsoptera
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		Duel.BreakEffect()
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end

function s.thfilterGuru(c)
    return c:IsSetCard(SET_SUBTERROR) and not c:IsCode(id) and c:IsAbleToHand()
end
