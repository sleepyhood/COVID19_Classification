############################
## 2023/06/08             
## 코로나 19 모델링, Feature Selection, 비교 및 시각화, 엑셀 쓰기
## SeungWon Oh            
############################
`
########공통 작업###########
# 1. 모든 패키지 다운로드
setRepositories(ind = 1:7)

# 2-1. 작업경로 설정(*단, 역슬래시 2번씩 표기)
WORK_DIR <- "C:\\Users\\osw\\Desktop\\#Workspace\\GIT_BackUp\\R\\COVID19_Classification"
setwd(WORK_DIR) # 작업디렉토리 설정
getwd() # 작업디렉토리 확인


# 3. 라이브러리 불러오기
## 그래프 함수
library(ggplot2)
library(gganimate)

##tibble() 자료형
library(tidyverse)

##날짜 처리 
library('lubridate')

## clean_names(), tabyl()
library('janitor')

## 문자열 내부에 변수 값 {x} 삽입
library(glue)

# 데이터프레임 기반 라이브러리
library(data.table)#fread를 사용하기 위한 라이브러리

library(caret)
library(robotstxt)
library(rvest) # 웹 스크래퍼
library(RSelenium)
library(dplyr)
library(httr)
library(jsonlite)

# 영어로 설정해야 월을 Date 객체로 바꿀 때 NA를 반환하지 않는다
Sys.setlocale("LC_TIME", "en_US.UTF-8")


##################
#[Instruction]
##################
# testSet에는 환자가 코로나인지 아닌지는 레이블이 없다.
trainSet<-fread('Q1_Train.txt')
dim(trainSet)
testSet<-fread('Q1_Test.txt')
dim(testSet)

str(trainSet)
str(testSet)

# na열은 없음을 확인
colSums(is.na(trainSet)) > 0
colSums(is.na(testSet)) > 0






##################
## Step 1
### 모든 features를 토대로 학습하기
##################

# 분류 문제=> 종속변수(Disease)는 범주형 자료여야함
# 성별, 인종, 기침 여부또한 범주로 구분할 수 있다.

trainSet$Disease<- factor(trainSet$Disease)
trainSet$Gender<- factor(trainSet$Gender)
trainSet$Race<- factor(trainSet$Race)
trainSet$HaveCough<- factor(trainSet$HaveCough)

#prop.table(table(trainSet$Disease,trainSet$Gender,trainSet$Race,trainSet$HaveCough ))

prop.table(table(trainSet$Gender,trainSet$Disease))
prop.table(table(trainSet$Race,trainSet$Disease))
prop.table(table(trainSet$HaveCough,trainSet$Disease))


# ID와 같은 문자열 데이터는 빼야함
trainSet <- trainSet %>% select(-ID)
str(trainSet)


# 모든 features를 가지고 10-fold 교차 검증
# 10 fold 기법
trainControl <- trainControl(method = "cv", number = 10,verboseIter =TRUE)
q1_step1_model_knn <- train(Disease~., data = trainSet,  method = 'knn', trControl = trainControl)
q1_step1_model_knn


# setwd(paste0(WORK_DIR, "\\Q1 모델 백업")) # 모델 백업 위치 지정
# getwd() # 백업 디렉토리 확인

saveRDS(q1_step1_model_knn, "q1_step1_model_knn.RData")
q1_step1_model_knn<-readRDS("q1_step1_model_knn.RData")


# 예측 결과
pred <- predict(q1_step1_model_knn, newdata = trainSet %>% select(-Disease))
pred

# Confusion Matrix 생성
# 모든 feature 후 결과
confusionMatrix(pred,trainSet$Disease)

sensitivity(pred,trainSet$Disease,positive = "COVID19" )
specificity(pred,trainSet$Disease,negative = "Healthy" )


##################
## Step 2
### features Selection & 전체 모델과 비교
##################

# 변수 중요도 계산
imp <- varImp(q1_step1_model_knn)
imp


# 중요한 변수 고르기
trainSetImp <-trainSet %>%  select(FEV1,FVC,Resting_SaO2,Age,Disease )

trainControl <- trainControl(method = "cv", number = 10,verboseIter =TRUE)
q1_step2_model_knn <- train(Disease~., data = trainSetImp,  method = 'knn', trControl = trainControl)
q1_step2_model_knn

q1_step2_model_knn$results$Accuracy


# knn모델 기준 feature 후 결과
pred <- predict(q1_step2_model_knn, newdata = trainSetImp %>% select(-Disease))

confusionMatrix(pred,trainSetImp$Disease)

##################
## Step 3
### 다른 모델과 비교
##################

# 모델 10개를 벡터로 모아 훈련하기
###########################################
trainControl <- trainControl(method = "cv", number = 10,verboseIter =TRUE)

# 모델 이름과 메소드 리스트
model_names <- c("knn", "ranger", "LogitBoost", "wsrf", "C5.0", "parRF", "treebag","glm", "earth", "rpart1SE")
methods <- model_names

###############

# 결과를 저장할 데이터프레임 생성
df <- data.frame(Model = character(), Accuracy = numeric(), stringsAsFactors = FALSE)

# 모델별로 학습 및 결과 저장
for (i in 1:length(model_names)) {
  print(model_names[i])
  model_name <- model_names[i]
  model <- train(Disease ~ ., data = trainSetImp, method = methods[i], trControl = trainControl)
  accuracy <- model$results$Accuracy
  
  saveRDS(model, paste0("Q1_Step3_filtered_model_", model_name, ".RData"))
  
  # 결과 데이터프레임에 추가
  df <- rbind(df, data.frame(Model = model_name, Accuracy = accuracy, stringsAsFactors = FALSE))
}

# 각 모델마다 정확도를 묶어서 순위를 매긴다.
df2<-df %>%
  group_by(Model) %>%
  mutate(Avg_Accuracy = mean(Accuracy)) %>%
  ungroup() %>%
  arrange(desc(Avg_Accuracy)) %>%
  mutate(Rank = dense_rank(-Avg_Accuracy)) %>% 
  arrange(Rank)

# 박스 플롯과 산점도 그래프를 같이 표기
df2 %>%
  ggplot(aes(x = factor(Model, levels = unique(Model)), y = Accuracy, fill = Model)) +
  geom_boxplot(fill = NA, aes(color = Model)) +
  geom_jitter(shape = 16, aes(color = Model), size = 6, alpha = 0.3) +
  xlab("Model") +
  ylab("Accuracy") +
  ggtitle("Accuracy by Model (Ranked)") +
  theme_minimal() +
  theme(legend.position = "bottom")


