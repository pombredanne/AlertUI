package com.jsi.alert.mq;

import java.util.HashMap;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageListener;
import javax.jms.TextMessage;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.jsi.alert.mq.callback.MsgCallback;
import com.jsi.alert.utils.Configuration;

public class MsgListener implements MessageListener {
	
	private static final Logger log = LoggerFactory.getLogger(MsgListener.class);
		
	private static final String REQUEST_ID_TAG = "<ns1:eventId>\\d+</ns1:eventId>";
	private static final Pattern REQUEST_ID_PATTERN = Pattern.compile(REQUEST_ID_TAG);

	private Map<String, MsgCallback> callbackH;
	
	public MsgListener() {
		callbackH = new HashMap<>();
	}
	
	@Override
	public void onMessage(Message message) {
		try {
			if (message instanceof TextMessage) {
				TextMessage received = (TextMessage) message;
				String text = received.getText();
				
				// check the ID
				Matcher matcher = REQUEST_ID_PATTERN.matcher(text);				
				if (matcher.find()) {
					String idTag = matcher.group(0);
					String eventId = idTag.replaceAll("<ns1:eventId>|</ns1:eventId>", "");
					
					MsgCallback callback = removeCallback(eventId);
					if (callback != null) {
						if (log.isDebugEnabled()) {
							log.debug("Received msg " + eventId + " dispatching...");
							if (Configuration.LOG_EVENTS)
								log.debug(text);
						}
						
						try {
							callback.onSuccess(text);
						} catch (Exception e) {
							log.error("An error occurred while dispatching msg, executing onFailure...", e);
							callback.onFailure();
						}
					}
				}
			}
		} catch (JMSException ex) {
			log.error("Failed to extract text from message, ignoring...", ex);
		}
	}
	
	private synchronized MsgCallback removeCallback(String requestId) {
		return callbackH.remove(requestId);
	}
	
	public synchronized void addCallback(final String requestId, MsgCallback callback) {
		callbackH.put(requestId, callback);
		
		// create a timer, which will remove the callback
		TimerTask removeTask = new TimerTask() {
			@Override
			public void run() {
				MsgCallback removed = removeCallback(requestId);
				if (removed != null) {
					if (log.isWarnEnabled())
						log.warn("Request " + requestId + " timed out, executing onFailure procedure...");
					removed.onFailure();
				}
			}
		};
		new Timer(true).schedule(removeTask, Configuration.REQUEST_TIMEOUT);
	}
}