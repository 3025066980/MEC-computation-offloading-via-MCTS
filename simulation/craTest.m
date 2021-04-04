function tests = craTest
    tests = functiontests(localfunctions);
end

%% testGenRandX
function testGenRandX(~)
    carNumber = 3;
    serverNumber = 2;
    sub_bandNumber = 2;
    X = GenRandX(carNumber, serverNumber,sub_bandNumber);
end
 
%% testCra
function testCra(~)
    carNumber = 3;
    serverNumber = 2;
    sub_bandNumber = 2;
    Fs = 10 + 40 * rand(serverNumber,1);  %������������������
    Fu = 10 + 40 * rand(carNumber,1);  %�û�������������
    T0.data = [];   %���������ݴ�С����������ʱ���������������С���
    T0.circle = [];
    T0.output = [];
    Tu = repmat(T0,carNumber);
    tu_local = zeros(carNumber,1);
    for i = 1:carNumber    %��ʼ���������
        Tu(i).data = 10 + 40 * rand;
        Tu(i).circle = 40 * rand;
        Tu(i).output = 4 * rand;
        tu_local(i) = Tu(i).circle/Fu(i);   %���ؼ���ʱ�����
    end
    Eta_car = zeros(carNumber,1);
    lamda = rand(carNumber,1);
    beta_time = rand(carNumber,1);
    for i=1:carNumber  %����CRA����Ħ�
        Eta_car(i) = beta_time(i) * Tu(i).circle * lamda(i) / tu_local(i);
    end
    X = GenRandX(carNumber, serverNumber,sub_bandNumber);
    [F,T] = cra(X,Fs,Eta_car);
    X
    F
    T
end