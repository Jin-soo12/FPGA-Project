# FPGA UART 제어구조 설계

---

## 📝요약
 FPGA보드(Basys3)를 활용하여 **UART**모듈을 직접 설계하고 UART 통신을 통해 센서(**HCSR04, DHT11**), **타이머**의 제어 시스템 설계가 목표입니다.

---
## 📚목차
- [개요](#개요)
- [설계 목표](#설계-목표)
- [Architecture](#Architecture)
- [Instruction Set](#Instruction-Set)
- [Simulation](#Simulation)
- [C Test Program Simulation](#C-Test-Program-Simulation)

---

## 📌개요
**RISC**  
RISC는 *Reduced Instruction Set Computer*의 약어로, 간소화된 명령어셋을 가진 컴퓨터 아키텍처입니다. CISC와 달리 명령어 수가 적고 구조가 단순하여 CPU 설계 학습에 매우 적합합니다.

**하버드 구조**  
한 저장장치가 Fetch/Store를 모두 하던 폰 노이만 구조와 달리, 명령어 메모리와 데이터 메모리를 분리하여 병목을 줄이고 파이프라인 구성을 용이하게 합니다.

<p align="center">
  <!-- 이미지/다이어그램 중앙 정렬 -->
  <img width="465" height="288" alt="image" src="https://github.com/user-attachments/assets/11455178-77b7-4268-98df-66b95ee38be2" />
</p>

---

## 🎯설계 목표
> RV32I 명령어셋의 이해 → CPU 설계 구현 → 시뮬레이션/검증  
최종 목표는 **전체 CPU 동작 원리 이해와 검증 완료** 입니다.

---

## 📗Architecture
### Block Diagram
<p align="center">
  <img width="1465" height="895" alt="image" src="https://github.com/user-attachments/assets/05a19830-1b96-4832-8ac0-2b57fb5a72cb" />
</p>

기본적으로 ROM과 RAM 및 CPU로 구성된 하버드 구조 및 Multi Cycle 구조로 설계하였습니다. Multi Cycle 구조는 기존 Single Cycle에 비해 보다 효율적인 Clock 사용을 할 수 있게 해줍니다. Single Cycle의 경우 CPU의 모든 로직이 Combinatinal Logic으로 이루어져 있어 Critical Path가 길어질 경우 소요되는 한 Clock이 매우 길어진다는 단점을 가지고 있습니다. 이 부분을 보완하고자 특정 기능을 하는 부분마다 
F/F을 넣어주어 각 Clock마다 정해진 역할 **(Fetch, Decode, Execute, Memory Access, Write Back)** 만 수행할 수 있도록 **Multi Cycle**구조로 구현하였습니다.

### FSM
<p align="center">
<img width="1445" height="890" alt="image" src="https://github.com/user-attachments/assets/b86c27ac-491e-4479-ba5e-60f83dece48c" />
</p>

FSM을 보면 Execute까지만 수행하는 명령어의 경우에는 Execute 수행 후 바로 Fetch 단계로 넘어가는 것을 볼 수 있고 메모리 접근이 필요한 명령어의 경우 메모리 접근까지 한 후 Fetch로 돌아오는 모습을 볼 수 있습니다.
이를 통해 각 명령어마다 소모되는 Clock의 수가 달라지는 것을 확인할 수 있고 이를 통해 보다 효율적인 Clock을 사용한다는 것 또한 확인이 가능 할 것입니다.

---

## 📕Instruction Set
### All-Type
<p align="center">
    <img width="1522" height="937" alt="image" src="https://github.com/user-attachments/assets/a2a5493a-7bd0-4d0f-8f35-a5d58df316a5" />
</p>

### R-Type
<p align="center">
  <img width="1355" height="815" alt="image" src="https://github.com/user-attachments/assets/eb0a7e01-0513-48d0-beee-80e8e536a65d" />
</p>

R-Type은 Register 간 연산 후 다시 Register File로 들어가는 Type입니다.

### L-Type
<p align="center">
  <img width="1341" height="818" alt="image" src="https://github.com/user-attachments/assets/0f2877fc-3ebc-4ee7-8e6f-376804aaeadf" />
</p>

L-Type은 RAM의 값을 Register File로 Load하는 Type입니다.

### I-Type
<p align="center">
  <img width="1335" height="815" alt="image" src="https://github.com/user-attachments/assets/607d38b7-6dbc-41db-9d51-c1beae445408" />
</p>

I-Type은 Immediate 값(즉시 값)과 Register 값을 연산하여 Register File로 다시 들어가는 Type입니다.

### S-Type
<p align="center">
  <img width="1336" height="817" alt="image" src="https://github.com/user-attachments/assets/f89fd687-81e0-4ee5-bab1-4b4a01ad12b0" />
</p>

S-Type은 Register 값을 RAM으로 Store하는 Type입니다.

### B-Type
<p align="center">
  <img width="1331" height="820" alt="image" src="https://github.com/user-attachments/assets/2ab27d74-d76e-47b3-a8c1-4e7084f486dd" />
</p>

B-Type은 특정 조건에 따라 Branch하는 Type입니다.

### LU-Type
<p align="center">
  <img width="1322" height="819" alt="image" src="https://github.com/user-attachments/assets/d3717cf6-0e84-493b-96ed-96205552554c" />
</p>

LU-Type은 Immediate << 12를 연산하여 Register File로 들어가는 Type입니다.

### AU-Type
<p align="center">
  <img width="1345" height="822" alt="image" src="https://github.com/user-attachments/assets/ebe5136d-d197-4bf8-8ee0-c9bd3fe4078f" />
</p>

AU-Type은 Program Counter + Immediate << 12 Register File로 들어가는 Type입니다.

### J-Type
<p align="center">
  <img width="1355" height="817" alt="image" src="https://github.com/user-attachments/assets/cb88b082-f09d-40c5-a96f-d6eb7ea849bf" />
</p>

J-Type은 다음 명령어 주소를 Register File에 저장 후 원하는 명령어 주소로 Jump하는 Type입니다.

### JL-Type
<p align="center">
  <img width="1347" height="820" alt="image" src="https://github.com/user-attachments/assets/f7d02073-d6da-4fda-a9c9-5078567b91ba" />
</p>

JL-Type 또한 다음 명령어 주소를 Register File에 저장 후 원하는 명령어 주소로 Jump하는 Type입니다.

---

## 📘Simulation

- 전체 Type을 다 작성하면 너무 길어지기 때문에 주요 타입만 보여드리겠습니다.

### R-Type Simulation
<p align="center">
  <img width="1777" height="932" alt="image" src="https://github.com/user-attachments/assets/e1c3a2d6-d1a1-46ec-a9ea-51f4c184f28c" />
</p>

### L-Type Simulation
<p align="center">
  <img width="1782" height="881" alt="image" src="https://github.com/user-attachments/assets/e926986f-4eac-4f54-a837-ff68c13b7e57" />
</p>
L-Type의 경우 Instruction Set을 보면 Word단위 뿐만 아니라 Byte 및 Half 단위까지 Load 할 수 있어야 하기 때문에 RAM 안에서도 Instruction Code를 받아 처리하도록 구현하였습니다.

### S-Type Simulation
<p align="center">
  <img width="1776" height="879" alt="image" src="https://github.com/user-attachments/assets/6fc3db0e-f632-4552-b098-097e540b5e5b" />
</p>
S-Type도 L-Typte과 마찬가지로 Byte 및 Half 단위까지 Store 할 수 있도록 설계를 진행하였습니다.

### B-Type Simulation
<p align="center">
  <img width="1790" height="894" alt="image" src="https://github.com/user-attachments/assets/17cc3da1-cbf8-4179-9a09-e30bdb8e6231" />
</p>

---

## 📙C Test Program Simulation
ROM Test Simulation 뿐만 아니라 실제 C Code를 컴파일한 머신코드를 제가 설계한 CPU에 적용시켜 명령어들이 정확히 설계 되었는지 확인 해보겠습니다.

### C Code
<p align="center">
<img width="628" height="864" alt="image" src="https://github.com/user-attachments/assets/fb0d5907-1dca-4838-b903-ecc9ec9a1a28" />
</p>

C Code상으로 동작은 기본적인 Sort함수를 구현한 코드이고 코드에서 보면 분기 및 점프, 연산, Load, Store까지 제가 설계한 명령어 대부분을 테스트 하기에
적합한 코드라고 생각하여 위의 C Code를 적용시켜봤습니다.

### Simulation
<p align="center">
<img width="1702" height="916" alt="image" src="https://github.com/user-attachments/assets/a4b53971-516a-4147-8128-75e3f61b0e8f" />
</p>
Stack Pointer의 이동 및 명령어의 분기가 잘 이뤄진 것을 볼 수 있고 C Code의 동작인 Sort까지 잘 이뤄진 모습을 볼 수 있습니다.
