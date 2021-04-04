function [max_objective, X, F] = task_offloading( ...
    CarNumber,...              % ��������
    serverNumber,...            % ����������
    sub_bandNumber,...          % �Ӵ�����
    T_min,...                   % �¶��½�
    alpha,...                   % �¶ȵ��½���
    k, ...                      % �����ռ�Ĵ�С
    para...                     % �������
)
%TA Task allocation,��������㷨������ģ���˻��㷨

    [x_old,fx_old,F] = genOriginX(CarNumber, serverNumber,sub_bandNumber,para);    %�õ���ʼ��
    
    picture = zeros(2,1);
    iterations = 1;
    T = CarNumber;
    max_objective = 0;
    
    while(T>T_min)
        for I=1:k
            x_new = getneighbourhood(x_old,CarNumber, serverNumber,sub_bandNumber);
            [fx_new, F_new] = Fx(x_new,para);
            delta = fx_new-fx_old;
            if (delta>0)
                x_old = x_new;
                fx_old = fx_new;
                if fx_new > max_objective
                    max_objective = fx_new;
                    X = x_new;
                    F = F_new;
                end
            else
                pro=getProbability(delta,T);
                if(pro>rand)
                    x_old=x_new;
                    fx_old = fx_new;
                end
            end
        end
        picture(iterations,1) = T;
        picture(iterations,2) = fx_old;
        iterations = iterations + 1;
        T=T*alpha;
    end
%     figure
%     plot(picture(:,1),picture(:,2),'b-.');
%     set(gca,'XDir','reverse');      %��X����ת
%     title('��׼ģ���˻��㷨������������Ż�');
%     xlabel('�¶�T');
%     ylabel('Ŀ�꺯��ֵ');
end
 
function res = getneighbourhood(x,CarNumber,serverNumber,sub_bandNumber)
    Car = unidrnd(CarNumber);     %ָ��Ҫ�Ŷ��ĳ�������
    flag_found = 0;
    for server = 1:serverNumber
        for band = 1:sub_bandNumber
            if x(Car,server,band) ~= 0
                flag_found = 1;
                break;  %�ҵ�����������ķ�������Ƶ��
            end
        end
        if flag_found == 1
            break;
        end
    end
    %�����Ŷ���ʽ���������߸�ֵ
    chosen = rand;
    if chosen > 0.2
        if chosen < 0.75   %55%�ĸ��ʸ��ĳ����ķ�������ѡ��offload��
            x(Car,server,band) = 0;
            vary_server = unidrnd(serverNumber);    %Ŀ�������
            vary_band = randi(sub_bandNumber);    %Ŀ��Ƶ��
            x(Car,vary_server,vary_band) = 1;
        else    %25%�ĸ��ʸ��ĳ�����Ƶ����ѡ��offload��
            if sub_bandNumber ~= 1
                x(Car,server,band) = 0;
                vary_band = unidrnd(sub_bandNumber);    %Ŀ��Ƶ��
                while vary_band == band
                    vary_band = unidrnd(sub_bandNumber);
                end
                x(Car,server,vary_band) = 1;
            end
        end
    else 
        if chosen > 0.05  %15%�ĸ��ʽ������������ķ�������Ƶ��
            if CarNumber ~= 1
                Car_other = unidrnd(CarNumber);    %ָ����һ������
                while Car_other == Car
                    Car_other = unidrnd(CarNumber);
                end
                flag_found = 0;
                for server_other = 1:serverNumber
                    for band_other=1:sub_bandNumber
                        if x(Car_other,server_other,band_other) ~= 0
                            flag_found = 1;
                            break;  %�ҵ���һ������������ķ�������Ƶ��
                        end
                    end
                    if flag_found == 1
                        break;
                    end
                end
                xValue =  x(Car,server,band);
                xValue_other =  x(Car_other,server_other,band_other);
                x(Car,server,band) = 0;
                x(Car_other,server_other,band_other) = 0;
                x(Car,server_other,band_other) = xValue_other;  %����Ƶ���ͷ�����
                x(Car_other,server,band) = xValue;
            end
        else    %5%�ĸ��ʸı�ó����ľ���
            x(Car,server,band) = 1 - x(Car,server,band);
        end
    end
    res = x;
end
 
function p = getProbability(delta,t)
    p = exp(delta/t);
end

function [seed,old_J,F] = genOriginX(CarNumber, serverNumber,sub_bandNumber,para)
%GenRandSeed    ��������Լ����������Ӿ���
    seed = zeros(CarNumber, serverNumber,sub_bandNumber);
    old_J = 0;
    for Car=1:CarNumber
        find = 0;
        for server=1:serverNumber
            for band=1:sub_bandNumber
                seed(Car,server,band) = 1;
                [new_J,new_F] = Fx(seed,para);
                if new_J > old_J
                    old_J = new_J;
                    F = new_F;
                    find = 1;
                    break;
                else
                    seed(Car,server,band) = 0;
                end
            end
            if find == 1
                break;
            end
        end
    end
end