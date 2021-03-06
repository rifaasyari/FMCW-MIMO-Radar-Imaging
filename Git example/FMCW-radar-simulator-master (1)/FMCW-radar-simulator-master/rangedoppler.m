function [ rhat,vhat ] = rangedoppler( cfg,rx )
	fs_n = cfg.fs/cfg.f_dec;
	B_CZT = fs_n/cfg.N;
    pfa = 1e-4;
	ntx = size(rx.rx1,1);
	skip = cfg.tmax*cfg.fs/cfg.f_dec;
    range = linspace(0,cfg.Rmax/2,cfg.N/cfg.nPulses/cfg.f_dec);
    vel = linspace(-cfg.vmax,cfg.vmax,cfg.nPulses);
    for i=1:rx.nrx
        for l=1:ntx
            eval(strcat('temp=rx.rx',int2str(i),'(',int2str(l),',',int2str(l),'*skip+1:cfg.N/cfg.nPulses/cfg.f_dec);'));
            N = length(temp);
            w = hamming(N).';
            foo = abs(fft(w.*temp));
            T = npwgnthresh(pfa);
            T = sqrt(cfg.sigma_n*db2pow(T));
            [~,ind] = findpeaks(abs(foo),'MinPeakHeight',T,'MinPeakProminence',T/2);
            nthat = length(ind);
            eval(strcat('tempvel=reshape(rx.rx',int2str(i),'(',int2str(l),',:),[',int2str(cfg.N/cfg.nPulses/cfg.f_dec),',',int2str(cfg.nPulses),']);'));
            rhat{i,l} = zeros(nthat,1);
            vhat{i,l} = zeros(nthat,1);
            for k = 1:nthat
                bar = fftshift(fft(tempvel(ind(k),:)));
                [~,velind] = max(abs(bar));
                vhat{i,l}(k) = vel(velind);
                fb = ind(k)/N*fs_n;
                f0 = fb-B_CZT/2;
                a_czt = exp(2i*pi*f0/fs_n);
                w_czt = exp(-2i*pi*B_CZT/(fs_n*N));
                eval(strcat('z = czt(rx.rx',int2str(i),'(',int2str(l),',:),cfg.N,w_czt,a_czt);'));
                [~,loc] = max(abs(z));
                fb_n = f0/2+loc*B_CZT/N/2;
                rhat{i,l}(k) = cfg.c*fb_n/cfg.mu;
            end
        end
    end
    rngdop = rx.rx1(1,:);
    rngdop = reshape(rngdop,[cfg.N/cfg.nPulses/cfg.f_dec,cfg.nPulses]);
    rngdop = fftshift(abs(fft2(rngdop)),2);
    rngdop = rngdop(1:end/2,:);
    imagesc(vel,range,20*log10(rngdop))
end
