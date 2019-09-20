# seoulbike

석사 학위 논문을 위해 진행한 연구를 R 패키지 형태로 제작하였습니다.  

대여소별로 수요 예측 모형을 적합하고 이를 바탕으로 실시간 수요 예측을 제공합니다. 실시간 수요 예측을 위해 서울 열린 데이터 광장의 오픈 API를 사용합니다. 

## Installation

devtools 패키지의 install_github 함수를 쓰면 편리하게 설치할 수 있습니다.

```R
devtools::install_github("subinjo92/seoulbike")
library('seoulbike')
```

## usage

실시간 예측을 위해 적합한 모형은 RData 형태로 저장하였습니다.  
https://o365skku-my.sharepoint.com/:f:/g/personal/vgd2468_o365_skku_edu/EhQZPJ2QVSxJrHecKc-dFx8BtBjON2msSDTMNvvcp7x9FA?e=RjDtkL  
위의 사이트에서 해당 모형을 대여소별로 받을 수 있습니다.  
R의 워킹 디렉토리에 prediction_model 폴더를 생성하고 해당 폴더에 모형 RData 파일을 저장하면 실시간 예측을 진행할 수 있습니다.

### real_time_bicycle
실시간 공공자전거 대여소의 현황을 제공하는 함수입니다. 확인하고 싶은 대여소 id와 서울 열린 데이터 광장의 api key를 입력하면 해당 대여소의 잔여 자전거 수와 정보를 확인할 수 있습니다.

### real_time_crawling
대여소 id와 서울 열린 데이터 광장의 api key를 통해 실시간 수요 예측을 위한 설명변수들을 수집합니다. 해당 대여소의 기상정보와 공기질 정보를 포함한 다양한 정보를 실시간 api를 통해 수집합니다. 기상정보의 경우 실시간 정보의 누락이 많아 1시간 전 자료를 수집하는 것이 좋습니다. 몇시간 전의 기상정보를 수집할지 설정할 수 있습니다.

### real_time_prediction
수요 예측 모형과 real_time_crawling함수를 통해 수집한 설명변수를 통해 특정 대여소의 1시간 동안 발생할 자전거 수요를 예측하는 함수입니다. 마찬가지로 대여소 id와 api key를 입력하면 사용할 수 있습니다. 먼저 위의 url을 통해 예측하고 싶은 대여소 모형을 저장한다음 진행하면 됩니다.

### real_time_prob
예측한 수요를 바탕으로 1시간 뒤 대여소를 방문했을 때, 대여 가능 확률을 계산하는 함수입니다. 마찬가지로 대여소 id와 api key를 입력하면 사용할 수 있습니다.

### real_time_plot
대여 가능 확률이 계산되는 근사적인 분포를 그려주는 함수입니다. 1시간 동안 발생가능한 수요값을 통해 근사적인 분포를 그립니다. 

## Data

### cycle_info
대여소의 정보를 포함하는 데이터입니다.

### cycle_log_c_14_fac
수요 예측 모형을 적합하는 훈련 데이터입니다.

### interest_area
파생변수 생성을 위한 데이터입니다.
