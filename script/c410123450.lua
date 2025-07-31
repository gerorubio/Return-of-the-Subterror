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
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- Special Summon Subterror from deck by flipping face down a Subterror monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.setcon1)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end

s.listed_series={SET_SUBTERROR}
s.listed_names={id}
function s.thfilter(c)
	return c:IsSetCard(SET_SUBTERROR) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.setcon1(e,tp,eg,ep,ev,re,r,rp)
	-- Checks if COUNT cards exist in locations S on PLAYER side of the field and O on their opponent's for which F returns true, except (Card ex)
	return not Duel.IsExistingMatchingCard(
		aux.FaceupFilter(Card.IsSetCard,SET_SUBTERROR), -- F
		tp, -- PLAYER
		LOCATION_ONFIELD, -- S
		0, -- O
		1, --  COUNT
		e:GetHandler()
	)
end

function s.setcon2(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_SUBTERROR),tp,LOCATION_ONFIELD,0,1,e:GetHandler())
end

function s.setfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc~=c and s.setfilter(chkc) end
	if chk==0 then return s.setfilter(c)
		and Duel.IsExistingTarget(s.setfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
	g:AddCard(c)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,2,0,0)
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local g=Group.FromCards(c,tc)
	if g:IsExists(function(c,e) return not c:IsFaceup() or not c:IsRelateToEffect(e) end,1,nil,e) then return end
	Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
end