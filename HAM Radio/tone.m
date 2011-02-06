    % pure tones

    clear

    freqs = 500;
    duration = 100;

    for i = 1:length(freqs)

    sampleFreq = 44100;
    dt = 1/sampleFreq;

    t = [0:dt:duration];

    s=sin(2*pi*freqs(i)*t);
    sound(s,sampleFreq);
    % wavName = sprintf(’tone%d.wav’,freqs(i));
    % wavwrite(s,sampleFreq,16,wavName);

    end