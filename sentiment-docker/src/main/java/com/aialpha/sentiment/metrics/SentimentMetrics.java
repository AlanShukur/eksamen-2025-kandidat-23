package com.aialpha.sentiment.metrics;

import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.Timer;
import io.micrometer.core.instrument.DistributionSummary;
import io.micrometer.core.instrument.Gauge;

import org.springframework.stereotype.Component;

import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.TimeUnit;

@Component
public class SentimentMetrics {

    private final MeterRegistry meterRegistry;
    
    // Atomic value for Gauge
    private final AtomicInteger lastDetectedCompanies = new AtomicInteger(0);


    // Constructor injection of MeterRegistry
    public SentimentMetrics(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;

        // Register gauge on creation (value kept in AtomicInteger)
        Gauge.builder("sentiment.detected_companies.gauge", lastDetectedCompanies, AtomicInteger::get)
                .description("Number of companies detected in the last sentiment analysis")
                .register(meterRegistry);
    }


    

    /**
     * Example implementation: Counter for sentiment analysis requests
     * This counter tracks the total number of sentiment analyses by sentiment type and company
     */
    public void recordAnalysis(String sentiment, String company) {
        Counter.builder("sentiment.analysis.total")
                .tag("sentiment", sentiment)
                .tag("company", company)
                .description("Total number of sentiment analysis requests")
                .register(meterRegistry)
                .increment();
    }

    /**
     * TIMER:
     * Measures duration of Bedrock API call in milliseconds.
     */
    public void recordDuration(long milliseconds, String company, String model) {
        Timer.builder("bedrock.api.latency")
                .description("Latency of AWS Bedrock sentiment analysis request")
                .tag("company", company)
                .tag("model", model)
                .publishPercentileHistogram()
                .publishPercentiles(0.5, 0.9, 0.99)
                .register(meterRegistry)
                .record(milliseconds, java.util.concurrent.TimeUnit.MILLISECONDS);
    }

    /**
     * GAUGE:
     * Tracks how many companies were found in the last analysis.
     */
    public void recordCompaniesDetected(int count) {
        lastDetectedCompanies.set(count);
    }

    /**
     * DISTRIBUTION SUMMARY:
     * Tracks statistical distribution of confidence scores.
     */
    public void recordConfidence(double confidence, String sentiment, String company) {
        DistributionSummary.builder("bedrock.confidence.distribution")
                .description("Distribution of confidence scores from Bedrock analysis")
                .tag("sentiment", sentiment)
                .tag("company", company)
                .baseUnit("score")
                .publishPercentiles(0.5, 0.9, 0.99)
                .register(meterRegistry)
                .record(confidence);
    }
}
