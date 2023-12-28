# COVID19_Classification
1. [개요](#개요)
2. [train과 test 데이터](#-train과-test데이터)
3. [KNN 혼동행렬](#-knn-혼동행렬)
4. [변수 중요도](#------)
5. [전체 변수 VS 중요도 높은 변수](#------vs----------)
6. [타 모델과 비교](#--------)

## 개요
* 이 코드는 COVID19 여부를 지도학습하여 모델링하는 코드입니다.
* 학부생 때 배운 내용을 토대로 하였습니다.
 
## train과 test데이터
![image](https://github.com/sleepyhood/COVID19_Classification/assets/69490791/0d45b500-ae57-4636-8098-df06f340e0b3)
* 종속변수 Disease열이 factor로 지정되어야만 알맞은 모델링이 가능합니다.

---

## KNN 혼동행렬
![image](https://github.com/sleepyhood/COVID19_Classification/assets/69490791/c826497c-72f5-4194-91a1-61cd8c6da8e1)
![image](https://github.com/sleepyhood/COVID19_Classification/assets/69490791/d9b2e30a-9f36-46e5-af1b-29830db72c1b)
* knn 모델을 기반으로, 혼동행렬을 구해줍니다.

---

## 변수 중요도
![image](https://github.com/sleepyhood/COVID19_Classification/assets/69490791/e1907f6c-bb94-4300-9140-94da6d6bd98c)
* caret 패키지의 varImp 함수를 사용하여 knn모델 기반으로 변수 중요도를 계산했습니다.
---

## 전체 변수 VS 중요도 높은 변수
![image](https://github.com/sleepyhood/COVID19_Classification/assets/69490791/d8056faf-bdf6-47b7-bf3e-fb1e1bf4358e)
![image](https://github.com/sleepyhood/COVID19_Classification/assets/69490791/ec9e418e-25c8-4fb7-9fab-ef0426fff68a)
* 상위 4개의 특징을 토대로 모델을 생성하였습니다.
* 전체 특징을 사용할 때 보다 약 3~4%정확도가 향상되었습니다.


## 타 모델과 비교
![image](https://github.com/sleepyhood/COVID19_Classification/assets/69490791/b0d28b50-6816-4ea3-b2dd-312039892208)
